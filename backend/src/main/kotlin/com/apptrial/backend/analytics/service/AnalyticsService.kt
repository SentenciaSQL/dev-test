package com.apptrial.backend.analytics.service

import com.apptrial.backend.applications.domain.ApplicationRepository
import com.apptrial.backend.campaigns.domain.CampaignRepository
import com.apptrial.backend.credits.domain.CreditWalletRepository
import com.apptrial.backend.feedback.domain.FeedbackReportRepository
import com.apptrial.backend.missions.domain.CampaignMissionRepository
import com.apptrial.backend.missions.domain.MissionSubmissionRepository
import com.apptrial.backend.shared.error.ForbiddenException
import com.apptrial.backend.shared.security.UserPrincipal
import com.apptrial.backend.testergroups.domain.CampaignGroupRepository
import com.apptrial.backend.testergroups.domain.GroupMemberRepository
import com.apptrial.backend.testergroups.service.TesterGroupService
import com.apptrial.backend.users.domain.UserRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

data class DeveloperAnalytics(
	val applications: Long,
	val campaigns: Long,
	val activeCampaigns: Long,
	val totalTargetTesters: Int,
	val occupiedSeats: Int,
	val missions: Long,
	val submissions: Long,
	val approvedSubmissions: Long,
	val feedbackReports: Long,
	val availableCredits: Int,
	val reservedCredits: Int,
)

data class PlatformAnalytics(
	val users: Long,
	val developers: Long,
	val testers: Long,
	val campaigns: Long,
	val submissions: Long,
	val feedbackReports: Long,
)

@Service
class AnalyticsService(
	private val applicationRepository: ApplicationRepository,
	private val campaignRepository: CampaignRepository,
	private val missionRepository: CampaignMissionRepository,
	private val submissionRepository: MissionSubmissionRepository,
	private val feedbackRepository: FeedbackReportRepository,
	private val groupRepository: CampaignGroupRepository,
	private val memberRepository: GroupMemberRepository,
	private val walletRepository: CreditWalletRepository,
	private val userRepository: UserRepository,
) {
	@Transactional(readOnly = true)
	fun developerOverview(userId: UUID): DeveloperAnalytics {
		val apps = applicationRepository.findAllByOwnerUserIdOrderByCreatedAtDesc(userId)
		val campaigns = campaignRepository.findAllByCreatedByUserIdOrderByCreatedAtDesc(userId)
		val active = campaigns.count { it.status !in setOf("CANCELLED", "COMPLETED", "EXPIRED", "DRAFT") }
		val missions = campaigns.flatMap { missionRepository.findAllByCampaignIdOrderBySortOrderAsc(it.id) }
		val submissions = missions.flatMap { submissionRepository.findAllByMissionIdOrderByCreatedAtDesc(it.id) }
		val feedback = campaigns.sumOf { feedbackRepository.findAllByCampaignIdOrderByCreatedAtDesc(it.id).size }
		val occupied = campaigns.sumOf { campaign ->
			groupRepository.findAllByCampaignIdOrderByCreatedAtAsc(campaign.id).sumOf { group ->
				memberRepository.countByGroupIdAndStatusIn(group.id, TesterGroupService.OCCUPYING_STATUSES).toInt()
			}
		}
		val wallet = walletRepository.findByUserId(userId)
		return DeveloperAnalytics(
			applications = apps.size.toLong(),
			campaigns = campaigns.size.toLong(),
			activeCampaigns = active.toLong(),
			totalTargetTesters = campaigns.sumOf { it.targetTesters },
			occupiedSeats = occupied,
			missions = missions.size.toLong(),
			submissions = submissions.size.toLong(),
			approvedSubmissions = submissions.count { it.status == "APPROVED" }.toLong(),
			feedbackReports = feedback.toLong(),
			availableCredits = wallet?.availableBalance ?: 0,
			reservedCredits = wallet?.reservedBalance ?: 0,
		)
	}

	@Transactional(readOnly = true)
	fun platformOverview(principal: UserPrincipal): PlatformAnalytics {
		if ("ADMIN" !in principal.roles) throw ForbiddenException("Admin role required")
		val users = userRepository.findAll()
		return PlatformAnalytics(
			users = users.size.toLong(),
			developers = users.count { "DEVELOPER" in it.roles }.toLong(),
			testers = users.count { "TESTER" in it.roles }.toLong(),
			campaigns = campaignRepository.count(),
			submissions = submissionRepository.count(),
			feedbackReports = feedbackRepository.count(),
		)
	}
}
