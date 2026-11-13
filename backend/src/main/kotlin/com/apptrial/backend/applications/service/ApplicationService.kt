package com.apptrial.backend.applications.service

import com.apptrial.backend.applications.api.ApplicationResponse
import com.apptrial.backend.applications.api.CreateApplicationRequest
import com.apptrial.backend.applications.api.UpdateApplicationRequest
import com.apptrial.backend.applications.domain.ApplicationEntity
import com.apptrial.backend.applications.domain.ApplicationRepository
import com.apptrial.backend.applications.domain.ApplicationScreenshotEntity
import com.apptrial.backend.applications.domain.ApplicationScreenshotRepository
import com.apptrial.backend.shared.error.ConflictException
import com.apptrial.backend.shared.error.ForbiddenException
import com.apptrial.backend.shared.error.NotFoundException
import com.apptrial.backend.shared.error.ValidationApiException
import com.apptrial.backend.shared.security.UserPrincipal
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

@Service
class ApplicationService(
	private val applicationRepository: ApplicationRepository,
	private val screenshotRepository: ApplicationScreenshotRepository,
) {
	companion object {
		private const val FREE_MAX_ACTIVE_APPS = 1
		private val allowedStatuses = setOf("ACTIVE", "ARCHIVED", "SUSPENDED")
	}

	@Transactional(readOnly = true)
	fun listMine(ownerId: UUID): List<ApplicationResponse> =
		applicationRepository.findAllByOwnerUserIdOrderByCreatedAtDesc(ownerId).map { toResponse(it) }

	@Transactional(readOnly = true)
	fun getOwned(id: UUID, ownerId: UUID): ApplicationResponse {
		val app = applicationRepository.findByIdAndOwnerUserId(id, ownerId)
			?: throw NotFoundException("Application not found")
		return toResponse(app)
	}

	@Transactional(readOnly = true)
	fun requireOwned(id: UUID, ownerId: UUID): ApplicationEntity =
		applicationRepository.findByIdAndOwnerUserId(id, ownerId)
			?: throw NotFoundException("Application not found")

	@Transactional(readOnly = true)
	fun getById(id: UUID): ApplicationEntity =
		applicationRepository.findById(id).orElseThrow { NotFoundException("Application not found") }

	@Transactional
	fun create(principal: UserPrincipal, request: CreateApplicationRequest): ApplicationResponse {
		requireDeveloper(principal)
		val packageName = request.packageName.trim()
		if (applicationRepository.existsByOwnerUserIdAndPackageNameIgnoreCase(principal.id, packageName)) {
			throw ConflictException("Package name already registered for this account")
		}
		val activeCount = applicationRepository.countByOwnerUserIdAndStatus(principal.id, "ACTIVE")
		if (activeCount >= FREE_MAX_ACTIVE_APPS) {
			throw ConflictException("Free plan allows only $FREE_MAX_ACTIVE_APPS active application")
		}

		val entity = applicationRepository.save(
			ApplicationEntity(
				ownerUserId = principal.id,
				name = request.name.trim(),
				description = request.description?.trim(),
				packageName = packageName,
				iconUrl = request.iconUrl,
				category = request.category?.trim(),
				currentVersion = request.currentVersion?.trim(),
				playStoreUrl = request.playStoreUrl,
				closedTestingUrl = request.closedTestingUrl,
				instructions = request.instructions,
			),
		)
		replaceScreenshots(entity.id, request.screenshotUrls)
		return toResponse(entity)
	}

	@Transactional
	fun update(principal: UserPrincipal, id: UUID, request: UpdateApplicationRequest): ApplicationResponse {
		requireDeveloper(principal)
		val entity = requireOwned(id, principal.id)
		request.name?.let { entity.name = it.trim() }
		request.description?.let { entity.description = it.trim() }
		request.iconUrl?.let { entity.iconUrl = it }
		request.category?.let { entity.category = it.trim() }
		request.currentVersion?.let { entity.currentVersion = it.trim() }
		request.playStoreUrl?.let { entity.playStoreUrl = it }
		request.closedTestingUrl?.let { entity.closedTestingUrl = it }
		request.instructions?.let { entity.instructions = it }
		request.status?.let {
			val status = it.uppercase()
			if (status !in allowedStatuses) {
				throw ValidationApiException("Invalid application status")
			}
			entity.status = status
		}
		entity.updatedAt = Instant.now()
		applicationRepository.save(entity)
		request.screenshotUrls?.let { replaceScreenshots(entity.id, it) }
		return toResponse(entity)
	}

	@Transactional
	fun archive(principal: UserPrincipal, id: UUID) {
		requireDeveloper(principal)
		val entity = requireOwned(id, principal.id)
		entity.status = "ARCHIVED"
		entity.updatedAt = Instant.now()
		applicationRepository.save(entity)
	}

	private fun replaceScreenshots(applicationId: UUID, urls: List<String>) {
		screenshotRepository.deleteAllByApplicationId(applicationId)
		urls.filter { it.isNotBlank() }.forEachIndexed { index, url ->
			screenshotRepository.save(
				ApplicationScreenshotEntity(
					applicationId = applicationId,
					imageUrl = url.trim(),
					sortOrder = index,
				),
			)
		}
	}

	private fun toResponse(entity: ApplicationEntity): ApplicationResponse {
		val screenshots = screenshotRepository
			.findAllByApplicationIdOrderBySortOrderAsc(entity.id)
			.map { it.imageUrl }
		return ApplicationResponse(
			id = entity.id.toString(),
			name = entity.name,
			description = entity.description,
			packageName = entity.packageName,
			iconUrl = entity.iconUrl,
			category = entity.category,
			currentVersion = entity.currentVersion,
			playStoreUrl = entity.playStoreUrl,
			closedTestingUrl = entity.closedTestingUrl,
			instructions = entity.instructions,
			status = entity.status,
			screenshotUrls = screenshots,
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
