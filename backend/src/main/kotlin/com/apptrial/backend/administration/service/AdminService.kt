package com.apptrial.backend.administration.service

import com.apptrial.backend.campaigns.domain.CampaignRepository
import com.apptrial.backend.credits.service.CreditWalletService
import com.apptrial.backend.shared.audit.AuditService
import com.apptrial.backend.shared.error.ForbiddenException
import com.apptrial.backend.shared.error.NotFoundException
import com.apptrial.backend.shared.error.ValidationApiException
import com.apptrial.backend.shared.security.UserPrincipal
import com.apptrial.backend.users.domain.UserEntity
import com.apptrial.backend.users.domain.UserRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.math.BigDecimal
import java.time.Instant
import java.util.UUID

data class AdminUserView(
	val id: String,
	val email: String,
	val displayName: String,
	val status: String,
	val roles: Set<String>,
	val reputationScore: BigDecimal,
	val createdAt: Instant,
)

data class FraudSignal(
	val userId: String,
	val email: String,
	val signal: String,
	val detail: String,
)

@Service
class AdminService(
	private val userRepository: UserRepository,
	private val campaignRepository: CampaignRepository,
	private val creditWalletService: CreditWalletService,
	private val auditService: AuditService,
) {
	@Transactional(readOnly = true)
	fun listUsers(principal: UserPrincipal): List<AdminUserView> {
		requireAdmin(principal)
		return userRepository.findAll().map { toView(it) }
	}

	@Transactional
	fun suspendUser(principal: UserPrincipal, userId: UUID, reason: String): AdminUserView {
		requireAdmin(principal)
		val user = userRepository.findById(userId).orElseThrow { NotFoundException("User not found") }
		user.status = "SUSPENDED"
		user.updatedAt = Instant.now()
		userRepository.save(user)
		auditService.record(
			actorUserId = principal.id,
			action = "USER_SUSPEND",
			entityType = "USER",
			entityId = userId,
			metadata = mapOf("reason" to reason),
		)
		return toView(user)
	}

	@Transactional
	fun activateUser(principal: UserPrincipal, userId: UUID): AdminUserView {
		requireAdmin(principal)
		val user = userRepository.findById(userId).orElseThrow { NotFoundException("User not found") }
		user.status = "ACTIVE"
		user.updatedAt = Instant.now()
		userRepository.save(user)
		auditService.record(
			actorUserId = principal.id,
			action = "USER_ACTIVATE",
			entityType = "USER",
			entityId = userId,
		)
		return toView(user)
	}

	@Transactional
	fun adjustCredits(
		principal: UserPrincipal,
		userId: UUID,
		amountTc: Int,
		reason: String,
	) {
		requireAdmin(principal)
		if (amountTc == 0) throw ValidationApiException("amountTc cannot be zero")
		val wallet = creditWalletService.getWallet(userId)
		creditWalletService.applyEntry(
			wallet = wallet,
			entryType = "ADMIN_ADJUST",
			amountTc = amountTc,
			creditOrigin = "PROMOTIONAL",
			idempotencyKey = "admin-adjust:$userId:${Instant.now().toEpochMilli()}",
			referenceType = "ADMIN",
			referenceId = principal.id,
			metadata = mapOf("reason" to reason),
		)
		auditService.record(
			actorUserId = principal.id,
			action = "CREDIT_ADJUST",
			entityType = "WALLET",
			entityId = wallet.id,
			metadata = mapOf("amountTc" to amountTc, "reason" to reason, "targetUserId" to userId.toString()),
		)
	}

	@Transactional
	fun cancelCampaign(principal: UserPrincipal, campaignId: UUID, reason: String) {
		requireAdmin(principal)
		val campaign = campaignRepository.findById(campaignId)
			.orElseThrow { NotFoundException("Campaign not found") }
		campaign.status = "CANCELLED"
		campaign.updatedAt = Instant.now()
		campaignRepository.save(campaign)
		auditService.record(
			actorUserId = principal.id,
			action = "CAMPAIGN_FORCE_CANCEL",
			entityType = "CAMPAIGN",
			entityId = campaignId,
			metadata = mapOf("reason" to reason),
		)
	}

	@Transactional(readOnly = true)
	fun fraudSignals(principal: UserPrincipal): List<FraudSignal> {
		requireAdmin(principal)
		val users = userRepository.findAll()
		val signals = mutableListOf<FraudSignal>()

		users.groupBy { it.displayName.trim().lowercase() }
			.filter { it.key.isNotBlank() && it.value.size > 1 }
			.forEach { (name, group) ->
				group.forEach { user ->
					signals += FraudSignal(
						userId = user.id.toString(),
						email = user.email,
						signal = "DUPLICATE_DISPLAY_NAME",
						detail = "Shared display name '$name' across ${group.size} accounts",
					)
				}
			}

		users.filter { it.reputationScore < BigDecimal.ZERO }.forEach { user ->
			signals += FraudSignal(
				userId = user.id.toString(),
				email = user.email,
				signal = "NEGATIVE_REPUTATION",
				detail = "Reputation ${user.reputationScore}",
			)
		}

		users.filter { it.status == "SUSPENDED" }.forEach { user ->
			signals += FraudSignal(
				userId = user.id.toString(),
				email = user.email,
				signal = "SUSPENDED_ACCOUNT",
				detail = "Account currently suspended",
			)
		}

		return signals
	}

	private fun requireAdmin(principal: UserPrincipal) {
		if ("ADMIN" !in principal.roles) throw ForbiddenException("Admin role required")
	}

	private fun toView(user: UserEntity) = AdminUserView(
		id = user.id.toString(),
		email = user.email,
		displayName = user.displayName,
		status = user.status,
		roles = user.roles.toSet(),
		reputationScore = user.reputationScore,
		createdAt = user.createdAt,
	)
}
