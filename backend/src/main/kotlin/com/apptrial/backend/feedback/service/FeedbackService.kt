package com.apptrial.backend.feedback.service

import com.apptrial.backend.campaigns.domain.CampaignRepository
import com.apptrial.backend.feedback.api.CreateFeedbackRequest
import com.apptrial.backend.feedback.api.FeedbackResponse
import com.apptrial.backend.feedback.domain.FeedbackReportEntity
import com.apptrial.backend.feedback.domain.FeedbackReportRepository
import com.apptrial.backend.shared.error.ForbiddenException
import com.apptrial.backend.shared.error.NotFoundException
import com.apptrial.backend.shared.error.ValidationApiException
import com.apptrial.backend.shared.security.UserPrincipal
import com.apptrial.backend.testergroups.domain.CampaignGroupRepository
import com.apptrial.backend.testergroups.domain.GroupMemberRepository
import com.apptrial.backend.testergroups.service.TesterGroupService
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

@Service
class FeedbackService(
	private val feedbackRepository: FeedbackReportRepository,
	private val campaignRepository: CampaignRepository,
	private val groupRepository: CampaignGroupRepository,
	private val memberRepository: GroupMemberRepository,
) {
	private val allowedTypes = setOf("BUG", "FEEDBACK", "OTHER")

	@Transactional
	fun create(campaignId: UUID, principal: UserPrincipal, request: CreateFeedbackRequest): FeedbackResponse {
		campaignRepository.findById(campaignId).orElseThrow { NotFoundException("Campaign not found") }
		assertParticipantOrOwner(campaignId, principal)
		val type = request.reportType.uppercase()
		if (type !in allowedTypes) {
			throw ValidationApiException("Invalid reportType", listOf("Allowed: BUG, FEEDBACK, OTHER"))
		}
		val entity = feedbackRepository.save(
			FeedbackReportEntity(
				campaignId = campaignId,
				userId = principal.id,
				reportType = type,
				title = request.title.trim(),
				body = request.body.trim(),
				severity = request.severity?.uppercase(),
			),
		)
		return toResponse(entity)
	}

	@Transactional(readOnly = true)
	fun listForCampaign(campaignId: UUID, principal: UserPrincipal): List<FeedbackResponse> {
		val campaign = campaignRepository.findById(campaignId)
			.orElseThrow { NotFoundException("Campaign not found") }
		val isOwner = campaign.createdByUserId == principal.id || "ADMIN" in principal.roles
		if (!isOwner) throw ForbiddenException("Only campaign owner can list all feedback")
		return feedbackRepository.findAllByCampaignIdOrderByCreatedAtDesc(campaignId).map { toResponse(it) }
	}

	@Transactional(readOnly = true)
	fun listMine(userId: UUID): List<FeedbackResponse> =
		feedbackRepository.findAllByUserIdOrderByCreatedAtDesc(userId).map { toResponse(it) }

	private fun assertParticipantOrOwner(campaignId: UUID, principal: UserPrincipal) {
		val campaign = campaignRepository.findById(campaignId)
			.orElseThrow { NotFoundException("Campaign not found") }
		if (campaign.createdByUserId == principal.id || "ADMIN" in principal.roles) return
		val ok = groupRepository.findAllByCampaignIdOrderByCreatedAtAsc(campaignId).any { g ->
			val m = memberRepository.findByGroupIdAndUserId(g.id, principal.id)
			m != null && m.status in TesterGroupService.OCCUPYING_STATUSES
		}
		if (!ok) throw ForbiddenException("Not a campaign participant")
	}

	private fun toResponse(entity: FeedbackReportEntity) = FeedbackResponse(
		id = entity.id.toString(),
		campaignId = entity.campaignId.toString(),
		userId = entity.userId.toString(),
		reportType = entity.reportType,
		title = entity.title,
		body = entity.body,
		severity = entity.severity,
		status = entity.status,
		createdAt = entity.createdAt,
	)
}
