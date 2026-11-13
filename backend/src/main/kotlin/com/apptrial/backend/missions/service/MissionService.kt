package com.apptrial.backend.missions.service

import com.apptrial.backend.campaigns.domain.CampaignRepository
import com.apptrial.backend.credits.service.CreditWalletService
import com.apptrial.backend.evidence.domain.EvidenceFileEntity
import com.apptrial.backend.evidence.domain.EvidenceFileRepository
import com.apptrial.backend.missions.api.CreateMissionRequest
import com.apptrial.backend.missions.api.EvidenceFileResponse
import com.apptrial.backend.missions.api.EvidenceUploadRequest
import com.apptrial.backend.missions.api.EvidenceUploadResponse
import com.apptrial.backend.missions.api.MissionResponse
import com.apptrial.backend.missions.api.ReviewSubmissionRequest
import com.apptrial.backend.missions.api.SubmissionResponse
import com.apptrial.backend.missions.api.SubmitMissionRequest
import com.apptrial.backend.missions.api.UpdateMissionRequest
import com.apptrial.backend.missions.domain.CampaignMissionEntity
import com.apptrial.backend.missions.domain.CampaignMissionRepository
import com.apptrial.backend.missions.domain.MissionSubmissionEntity
import com.apptrial.backend.missions.domain.MissionSubmissionRepository
import com.apptrial.backend.shared.error.ConflictException
import com.apptrial.backend.shared.error.ForbiddenException
import com.apptrial.backend.shared.error.NotFoundException
import com.apptrial.backend.shared.error.ValidationApiException
import com.apptrial.backend.shared.security.UserPrincipal
import com.apptrial.backend.shared.storage.EvidenceStorage
import com.apptrial.backend.testergroups.domain.CampaignGroupRepository
import com.apptrial.backend.testergroups.domain.GroupMemberRepository
import com.apptrial.backend.testergroups.service.TesterGroupService
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

@Service
class MissionService(
	private val missionRepository: CampaignMissionRepository,
	private val submissionRepository: MissionSubmissionRepository,
	private val evidenceRepository: EvidenceFileRepository,
	private val campaignRepository: CampaignRepository,
	private val groupRepository: CampaignGroupRepository,
	private val memberRepository: GroupMemberRepository,
	private val creditWalletService: CreditWalletService,
	private val evidenceStorage: EvidenceStorage,
) {
	@Transactional(readOnly = true)
	fun listMissions(campaignId: UUID, viewer: UserPrincipal): List<MissionResponse> {
		assertCanViewCampaign(campaignId, viewer)
		return missionRepository.findAllByCampaignIdOrderBySortOrderAsc(campaignId).map { toMission(it) }
	}

	@Transactional
	fun createMission(campaignId: UUID, principal: UserPrincipal, request: CreateMissionRequest): MissionResponse {
		val campaign = requireOwnedCampaign(campaignId, principal)
		val entity = missionRepository.save(
			CampaignMissionEntity(
				campaignId = campaign.id,
				title = request.title.trim(),
				description = request.description,
				instructions = request.instructions,
				missionType = request.missionType.uppercase(),
				rewardTc = request.rewardTc,
				dueAt = request.dueAt,
				evidenceRequired = request.evidenceRequired,
				sortOrder = request.sortOrder,
			),
		)
		return toMission(entity)
	}

	@Transactional
	fun updateMission(
		campaignId: UUID,
		missionId: UUID,
		principal: UserPrincipal,
		request: UpdateMissionRequest,
	): MissionResponse {
		requireOwnedCampaign(campaignId, principal)
		val entity = missionRepository.findByIdAndCampaignId(missionId, campaignId)
			?: throw NotFoundException("Mission not found")
		request.title?.let { entity.title = it.trim() }
		request.description?.let { entity.description = it }
		request.instructions?.let { entity.instructions = it }
		request.missionType?.let { entity.missionType = it.uppercase() }
		request.rewardTc?.let { entity.rewardTc = it }
		request.dueAt?.let { entity.dueAt = it }
		request.evidenceRequired?.let { entity.evidenceRequired = it }
		request.sortOrder?.let { entity.sortOrder = it }
		request.status?.let {
			val status = it.uppercase()
			if (status !in setOf("ACTIVE", "DISABLED")) {
				throw ValidationApiException("Invalid mission status")
			}
			entity.status = status
		}
		entity.updatedAt = Instant.now()
		return toMission(missionRepository.save(entity))
	}

	@Transactional
	fun submit(
		missionId: UUID,
		principal: UserPrincipal,
		request: SubmitMissionRequest,
	): SubmissionResponse {
		requireTester(principal)
		val mission = missionRepository.findById(missionId).orElseThrow { NotFoundException("Mission not found") }
		if (mission.status != "ACTIVE") throw ConflictException("Mission is not active")
		assertTesterInCampaign(mission.campaignId, principal.id)

		val existing = submissionRepository.findByMissionIdAndUserId(missionId, principal.id)
		val now = Instant.now()
		val submission = if (existing == null) {
			submissionRepository.save(
				MissionSubmissionEntity(
					missionId = missionId,
					userId = principal.id,
					description = request.description,
					status = "SUBMITTED",
				),
			)
		} else {
			if (existing.status in setOf("APPROVED", "UNDER_REVIEW")) {
				throw ConflictException("Submission cannot be modified in status ${existing.status}")
			}
			existing.description = request.description
			existing.status = "SUBMITTED"
			existing.updatedAt = now
			submissionRepository.save(existing)
		}
		return toSubmission(submission)
	}

	@Transactional(readOnly = true)
	fun listSubmissionsForMission(missionId: UUID, principal: UserPrincipal): List<SubmissionResponse> {
		val mission = missionRepository.findById(missionId).orElseThrow { NotFoundException("Mission not found") }
		requireOwnedCampaign(mission.campaignId, principal)
		return submissionRepository.findAllByMissionIdOrderByCreatedAtDesc(missionId).map { toSubmission(it) }
	}

	@Transactional(readOnly = true)
	fun listMySubmissions(userId: UUID): List<SubmissionResponse> =
		submissionRepository.findAllByUserIdOrderByCreatedAtDesc(userId).map { toSubmission(it) }

	@Transactional
	fun review(
		submissionId: UUID,
		principal: UserPrincipal,
		request: ReviewSubmissionRequest,
	): SubmissionResponse {
		val submission = submissionRepository.findById(submissionId)
			.orElseThrow { NotFoundException("Submission not found") }
		val mission = missionRepository.findById(submission.missionId)
			.orElseThrow { NotFoundException("Mission not found") }
		requireOwnedCampaign(mission.campaignId, principal)

		val status = request.status.uppercase()
		if (status !in setOf("UNDER_REVIEW", "APPROVED", "REJECTED")) {
			throw ValidationApiException("Invalid review status")
		}
		if (submission.status !in setOf("SUBMITTED", "UNDER_REVIEW", "REJECTED")) {
			throw ConflictException("Cannot review submission in status ${submission.status}")
		}
		if (status == "APPROVED" && mission.evidenceRequired) {
			val count = evidenceRepository.countBySubmissionId(submission.id)
			if (count == 0L) throw ConflictException("Evidence required before approval")
		}

		val now = Instant.now()
		submission.status = status
		submission.reviewerNotes = request.reviewerNotes
		submission.reviewedBy = principal.id
		submission.reviewedAt = now
		submission.updatedAt = now
		submissionRepository.save(submission)

		if (status == "APPROVED" && mission.rewardTc > 0) {
			val wallet = creditWalletService.getWallet(submission.userId)
			creditWalletService.applyEntry(
				wallet = wallet,
				entryType = "REWARD",
				amountTc = mission.rewardTc,
				creditOrigin = "PROMOTIONAL",
				idempotencyKey = "mission-reward:${submission.id}",
				referenceType = "MISSION_SUBMISSION",
				referenceId = submission.id,
				metadata = mapOf(
					"missionId" to mission.id.toString(),
					"campaignId" to mission.campaignId.toString(),
				),
			)
		}
		return toSubmission(submission)
	}

	@Transactional
	fun requestEvidenceUpload(
		submissionId: UUID,
		principal: UserPrincipal,
		request: EvidenceUploadRequest,
	): EvidenceUploadResponse {
		val submission = submissionRepository.findByIdAndUserId(submissionId, principal.id)
			?: throw NotFoundException("Submission not found")
		if (submission.status !in setOf("PENDING", "SUBMITTED", "REJECTED")) {
			throw ConflictException("Cannot add evidence in status ${submission.status}")
		}
		val upload = evidenceStorage.createUpload(submission.id, request.contentType)
		val evidence = evidenceRepository.save(
			EvidenceFileEntity(
				submissionId = submission.id,
				storageKey = upload.storageKey,
				contentType = request.contentType,
				sizeBytes = request.sizeBytes,
			),
		)
		if (submission.status == "PENDING") {
			submission.status = "SUBMITTED"
			submission.updatedAt = Instant.now()
			submissionRepository.save(submission)
		}
		return EvidenceUploadResponse(
			evidenceId = evidence.id.toString(),
			storageKey = upload.storageKey,
			uploadUrl = upload.uploadUrl,
			expiresAt = upload.expiresAt,
		)
	}

	@Transactional(readOnly = true)
	fun listEvidence(submissionId: UUID, principal: UserPrincipal): List<EvidenceFileResponse> {
		val submission = submissionRepository.findById(submissionId)
			.orElseThrow { NotFoundException("Submission not found") }
		val mission = missionRepository.findById(submission.missionId)
			.orElseThrow { NotFoundException("Mission not found") }
		val campaign = campaignRepository.findById(mission.campaignId)
			.orElseThrow { NotFoundException("Campaign not found") }
		val allowed = submission.userId == principal.id ||
			campaign.createdByUserId == principal.id ||
			"ADMIN" in principal.roles
		if (!allowed) throw ForbiddenException()
		return evidenceRepository.findAllBySubmissionIdOrderByCreatedAtAsc(submissionId).map {
			EvidenceFileResponse(
				id = it.id.toString(),
				storageKey = it.storageKey,
				contentType = it.contentType,
				sizeBytes = it.sizeBytes,
				createdAt = it.createdAt,
			)
		}
	}

	private fun assertCanViewCampaign(campaignId: UUID, viewer: UserPrincipal) {
		val campaign = campaignRepository.findById(campaignId)
			.orElseThrow { NotFoundException("Campaign not found") }
		val isOwner = campaign.createdByUserId == viewer.id || "ADMIN" in viewer.roles
		if (isOwner) return
		assertTesterInCampaign(campaignId, viewer.id)
	}

	private fun assertTesterInCampaign(campaignId: UUID, userId: UUID) {
		val groups = groupRepository.findAllByCampaignIdOrderByCreatedAtAsc(campaignId)
		val ok = groups.any { g ->
			val m = memberRepository.findByGroupIdAndUserId(g.id, userId)
			m != null && m.status in TesterGroupService.OCCUPYING_STATUSES
		}
		if (!ok) throw ForbiddenException("Not a campaign participant")
	}

	private fun requireOwnedCampaign(campaignId: UUID, principal: UserPrincipal) =
		campaignRepository.findById(campaignId).orElseThrow { NotFoundException("Campaign not found") }
			.also {
				if (it.createdByUserId != principal.id && "ADMIN" !in principal.roles) {
					throw ForbiddenException("Not campaign owner")
				}
			}

	private fun requireTester(principal: UserPrincipal) {
		if ("TESTER" !in principal.roles && "ADMIN" !in principal.roles) {
			throw ForbiddenException("Tester role required")
		}
	}

	private fun toMission(entity: CampaignMissionEntity) = MissionResponse(
		id = entity.id.toString(),
		campaignId = entity.campaignId.toString(),
		title = entity.title,
		description = entity.description,
		instructions = entity.instructions,
		missionType = entity.missionType,
		rewardTc = entity.rewardTc,
		dueAt = entity.dueAt,
		evidenceRequired = entity.evidenceRequired,
		sortOrder = entity.sortOrder,
		status = entity.status,
	)

	private fun toSubmission(entity: MissionSubmissionEntity) = SubmissionResponse(
		id = entity.id.toString(),
		missionId = entity.missionId.toString(),
		userId = entity.userId.toString(),
		description = entity.description,
		status = entity.status,
		reviewerNotes = entity.reviewerNotes,
		reviewedAt = entity.reviewedAt,
		evidenceCount = evidenceRepository.countBySubmissionId(entity.id),
		createdAt = entity.createdAt,
	)
}
