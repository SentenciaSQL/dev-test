package com.apptrial.backend.administration.api

import com.apptrial.backend.administration.service.AdminService
import com.apptrial.backend.administration.service.AdminUserView
import com.apptrial.backend.administration.service.FraudSignal
import com.apptrial.backend.shared.audit.AuditLogEntity
import com.apptrial.backend.shared.audit.AuditService
import com.apptrial.backend.shared.web.SecurityUtils
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

data class SuspendRequest(@field:NotBlank val reason: String)
data class AdjustCreditsRequest(
	@field:NotNull val amountTc: Int,
	@field:NotBlank val reason: String,
)
data class CancelCampaignRequest(@field:NotBlank val reason: String)

@RestController
@RequestMapping("/api/v1/admin")
class AdminController(
	private val adminService: AdminService,
	private val auditService: AuditService,
) {
	@GetMapping("/users")
	fun users(): List<AdminUserView> = adminService.listUsers(SecurityUtils.currentUser())

	@PostMapping("/users/{userId}/suspend")
	fun suspend(@PathVariable userId: UUID, @RequestBody body: SuspendRequest): AdminUserView =
		adminService.suspendUser(SecurityUtils.currentUser(), userId, body.reason)

	@PostMapping("/users/{userId}/activate")
	fun activate(@PathVariable userId: UUID): AdminUserView =
		adminService.activateUser(SecurityUtils.currentUser(), userId)

	@PostMapping("/users/{userId}/credits/adjust")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	fun adjustCredits(@PathVariable userId: UUID, @RequestBody body: AdjustCreditsRequest) {
		adminService.adjustCredits(SecurityUtils.currentUser(), userId, body.amountTc, body.reason)
	}

	@PostMapping("/campaigns/{campaignId}/cancel")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	fun cancelCampaign(@PathVariable campaignId: UUID, @RequestBody body: CancelCampaignRequest) {
		adminService.cancelCampaign(SecurityUtils.currentUser(), campaignId, body.reason)
	}

	@GetMapping("/fraud-signals")
	fun fraudSignals(): List<FraudSignal> = adminService.fraudSignals(SecurityUtils.currentUser())

	@GetMapping("/audit-logs")
	fun auditLogs(@RequestParam(defaultValue = "100") limit: Int): List<AuditLogEntity> {
		val principal = SecurityUtils.currentUser()
		adminService.listUsers(principal) // enforces admin
		return auditService.recent(limit.coerceIn(1, 500))
	}
}
