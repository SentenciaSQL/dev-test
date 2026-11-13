package com.apptrial.backend.campaigns.service

import com.apptrial.backend.applications.service.ApplicationService
import com.apptrial.backend.campaigns.api.CampaignResponse
import com.apptrial.backend.campaigns.api.CreateCampaignRequest
import com.apptrial.backend.campaigns.api.UpdateCampaignRequest
import com.apptrial.backend.campaigns.domain.CampaignEntity
import com.apptrial.backend.campaigns.domain.CampaignRepository
import com.apptrial.backend.credits.domain.CreditReservationEntity
import com.apptrial.backend.credits.domain.CreditReservationRepository
import com.apptrial.backend.credits.service.CreditWalletService
import com.apptrial.backend.shared.config.AppProperties
import com.apptrial.backend.shared.error.ConflictException
import com.apptrial.backend.shared.error.ForbiddenException
import com.apptrial.backend.shared.error.NotFoundException
import com.apptrial.backend.shared.error.ValidationApiException
import com.apptrial.backend.shared.security.UserPrincipal
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.time.temporal.ChronoUnit
import java.util.UUID

@Service
class CampaignService(
	private val campaignRepository: CampaignRepository,
	private val applicationService: ApplicationService,
	private val creditWalletService: CreditWalletService,
	private val reservationRepository: CreditReservationRepository,
	private val props: AppProperties,
) {
	companion object {
		private const val FREE_MAX_CAMPAIGNS = 1
		private val editableStatuses = setOf("DRAFT")
		private val exploreStatuses = setOf("PUBLISHED", "RECRUITING")
		private val terminalStatuses = setOf("CANCELLED", "COMPLETED", "EXPIRED")
	}

	@Transactional(readOnly = true)
	fun listMine(userId: UUID): List<CampaignResponse> =
		campaignRepository.findAllByCreatedByUserIdOrderByCreatedAtDesc(userId).map { toResponse(it) }

	@Transactional(readOnly = true)
	fun get(id: UUID, viewer: UserPrincipal): CampaignResponse {
		val campaign = campaignRepository.findById(id).orElseThrow { NotFoundException("Campaign not found") }
		val isOwner = campaign.createdByUserId == viewer.id || "ADMIN" in viewer.roles
		val isPublic = campaign.status in exploreStatuses || campaign.status == "ACTIVE"
		if (!isOwner && !isPublic) {
			throw ForbiddenException("Campaign is not available")
		}
		return toResponse(campaign)
	}

	@Transactional(readOnly = true)
	fun explore(countryCode: String?, sdkInt: Int?): List<CampaignResponse> {
		val country = countryCode?.uppercase()
		return campaignRepository.findAllByStatusInOrderByCreatedAtDesc(exploreStatuses)
			.filter { matchesFilters(it, country, sdkInt) }
			.map { toResponse(it) }
	}

	@Transactional
	fun create(principal: UserPrincipal, request: CreateCampaignRequest): CampaignResponse {
		requireDeveloper(principal)
		val applicationId = UUID.fromString(request.applicationId)
		val app = applicationService.requireOwned(applicationId, principal.id)
		if (app.status != "ACTIVE") {
			throw ConflictException("Application must be ACTIVE to create campaigns")
		}

		val activeCampaigns = campaignRepository.countByCreatedByUserIdAndStatusNotIn(
			principal.id,
			terminalStatuses,
		)
		if (activeCampaigns >= FREE_MAX_CAMPAIGNS) {
			throw ConflictException("Free plan allows only $FREE_MAX_CAMPAIGNS non-terminal campaign")
		}

		validateTargets(request.targetTesters, request.minAndroidSdk, request.maxAndroidSdk)
		val cost = CampaignPricing.costPerTesterTc(request.durationDays)
		val startsAt = request.startsAt
		val endsAt = startsAt?.plus(request.durationDays.toLong(), ChronoUnit.DAYS)

		val entity = campaignRepository.save(
			CampaignEntity(
				applicationId = app.id,
				createdByUserId = principal.id,
				name = request.name.trim(),
				description = request.description?.trim(),
				testType = request.testType.uppercase().ifBlank { "CLOSED" },
				durationDays = request.durationDays,
				startsAt = startsAt,
				endsAt = endsAt,
				targetTesters = request.targetTesters,
				allowedCountries = normalizeCountries(request.allowedCountries),
				minAndroidSdk = request.minAndroidSdk,
				maxAndroidSdk = request.maxAndroidSdk,
				instructions = request.instructions,
				status = "DRAFT",
				costPerTesterTc = cost,
			),
		)
		return toResponse(entity)
	}

	@Transactional
	fun update(principal: UserPrincipal, id: UUID, request: UpdateCampaignRequest): CampaignResponse {
		requireDeveloper(principal)
		val entity = campaignRepository.findByIdAndCreatedByUserId(id, principal.id)
			?: throw NotFoundException("Campaign not found")
		if (entity.status !in editableStatuses) {
			throw ConflictException("Only DRAFT campaigns can be edited")
		}

		request.name?.let { entity.name = it.trim() }
		request.description?.let { entity.description = it.trim() }
		request.testType?.let { entity.testType = it.uppercase() }
		request.durationDays?.let {
			entity.durationDays = it
			entity.costPerTesterTc = CampaignPricing.costPerTesterTc(it)
			entity.endsAt = entity.startsAt?.plus(it.toLong(), ChronoUnit.DAYS)
		}
		request.startsAt?.let {
			entity.startsAt = it
			entity.endsAt = it.plus(entity.durationDays.toLong(), ChronoUnit.DAYS)
		}
		request.targetTesters?.let {
			validateTargets(it, request.minAndroidSdk ?: entity.minAndroidSdk, request.maxAndroidSdk ?: entity.maxAndroidSdk)
			entity.targetTesters = it
		}
		request.allowedCountries?.let { entity.allowedCountries = normalizeCountries(it) }
		request.minAndroidSdk?.let { entity.minAndroidSdk = it }
		request.maxAndroidSdk?.let { entity.maxAndroidSdk = it }
		request.instructions?.let { entity.instructions = it }
		entity.updatedAt = Instant.now()
		return toResponse(campaignRepository.save(entity))
	}

	@Transactional
	fun publish(principal: UserPrincipal, id: UUID): CampaignResponse {
		requireDeveloper(principal)
		val entity = campaignRepository.findByIdAndCreatedByUserId(id, principal.id)
			?: throw NotFoundException("Campaign not found")
		if (entity.status != "DRAFT") {
			throw ConflictException("Only DRAFT campaigns can be published")
		}
		val app = applicationService.requireOwned(entity.applicationId, principal.id)
		if (app.status != "ACTIVE") {
			throw ConflictException("Application must be ACTIVE")
		}
		if (entity.targetTesters < props.credits.minGroupSize) {
			throw ValidationApiException("targetTesters must be at least ${props.credits.minGroupSize}")
		}

		val totalCost = entity.totalCostTc()
		val wallet = creditWalletService.getWallet(principal.id)
		creditWalletService.applyEntry(
			wallet = wallet,
			entryType = "RESERVE",
			amountTc = totalCost,
			idempotencyKey = "campaign-reserve:${entity.id}",
			referenceType = "CAMPAIGN",
			referenceId = entity.id,
			metadata = mapOf(
				"targetTesters" to entity.targetTesters,
				"costPerTesterTc" to entity.costPerTesterTc,
			),
		)
		reservationRepository.save(
			CreditReservationEntity(
				walletId = wallet.id,
				campaignId = entity.id,
				amountTc = totalCost,
				status = "OPEN",
			),
		)

		val now = Instant.now()
		if (entity.startsAt == null) {
			entity.startsAt = now
			entity.endsAt = now.plus(entity.durationDays.toLong(), ChronoUnit.DAYS)
		}
		entity.status = "RECRUITING"
		entity.updatedAt = now
		return toResponse(campaignRepository.save(entity))
	}

	@Transactional
	fun cancel(principal: UserPrincipal, id: UUID): CampaignResponse {
		requireDeveloper(principal)
		val entity = campaignRepository.findByIdAndCreatedByUserId(id, principal.id)
			?: throw NotFoundException("Campaign not found")
		if (entity.status in terminalStatuses) {
			throw ConflictException("Campaign already terminal")
		}

		if (entity.status != "DRAFT") {
			val reservation = reservationRepository.findByCampaignIdAndStatus(entity.id, "OPEN")
			if (reservation != null) {
				val wallet = creditWalletService.getWallet(principal.id)
				creditWalletService.applyEntry(
					wallet = wallet,
					entryType = "RELEASE",
					amountTc = reservation.amountTc,
					idempotencyKey = "campaign-release:${entity.id}",
					referenceType = "CAMPAIGN",
					referenceId = entity.id,
				)
				reservation.status = "RELEASED"
				reservation.updatedAt = Instant.now()
				reservationRepository.save(reservation)
			}
		}

		entity.status = "CANCELLED"
		entity.updatedAt = Instant.now()
		return toResponse(campaignRepository.save(entity))
	}

	private fun matchesFilters(campaign: CampaignEntity, country: String?, sdkInt: Int?): Boolean {
		val countries = campaign.allowedCountries
		if (country != null && countries.isNotEmpty() && country !in countries) {
			return false
		}
		if (sdkInt != null) {
			campaign.minAndroidSdk?.let { if (sdkInt < it) return false }
			campaign.maxAndroidSdk?.let { if (sdkInt > it) return false }
		}
		return true
	}

	private fun validateTargets(targetTesters: Int, minSdk: Int?, maxSdk: Int?) {
		if (targetTesters < props.credits.minGroupSize) {
			throw ValidationApiException("targetTesters must be at least ${props.credits.minGroupSize}")
		}
		if (minSdk != null && maxSdk != null && minSdk > maxSdk) {
			throw ValidationApiException("minAndroidSdk cannot be greater than maxAndroidSdk")
		}
	}

	private fun normalizeCountries(countries: List<String>): Array<String> =
		countries.map { it.trim().uppercase() }
			.filter { it.length == 2 }
			.distinct()
			.toTypedArray()

	private fun toResponse(entity: CampaignEntity): CampaignResponse {
		val appName = runCatching { applicationService.getById(entity.applicationId).name }.getOrNull()
		return CampaignResponse(
			id = entity.id.toString(),
			applicationId = entity.applicationId.toString(),
			applicationName = appName,
			name = entity.name,
			description = entity.description,
			testType = entity.testType,
			durationDays = entity.durationDays,
			startsAt = entity.startsAt,
			endsAt = entity.endsAt,
			targetTesters = entity.targetTesters,
			allowedCountries = entity.allowedCountries.toList(),
			minAndroidSdk = entity.minAndroidSdk,
			maxAndroidSdk = entity.maxAndroidSdk,
			instructions = entity.instructions,
			status = entity.status,
			costPerTesterTc = entity.costPerTesterTc,
			totalCostTc = entity.totalCostTc(),
			createdAt = entity.createdAt,
			updatedAt = entity.updatedAt,
		)
	}

	private fun requireDeveloper(principal: UserPrincipal) {
		if ("DEVELOPER" !in principal.roles && "ADMIN" !in principal.roles) {
			throw ForbiddenException("Developer role required")
		}
	}
}
