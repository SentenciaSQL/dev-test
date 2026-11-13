package com.apptrial.backend.missions.api

import jakarta.validation.constraints.Min
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size
import java.time.Instant

data class CreateMissionRequest(
	@field:NotBlank @field:Size(max = 160)
	val title: String,
	val description: String? = null,
	val instructions: String? = null,
	@field:NotBlank
	val missionType: String,
	@field:Min(0)
	val rewardTc: Int = 0,
	val dueAt: Instant? = null,
	val evidenceRequired: Boolean = true,
	val sortOrder: Int = 0,
)

data class UpdateMissionRequest(
	val title: String? = null,
	val description: String? = null,
	val instructions: String? = null,
	val missionType: String? = null,
	@field:Min(0)
	val rewardTc: Int? = null,
	val dueAt: Instant? = null,
	val evidenceRequired: Boolean? = null,
	val sortOrder: Int? = null,
	val status: String? = null,
)

data class MissionResponse(
	val id: String,
	val campaignId: String,
	val title: String,
	val description: String?,
	val instructions: String?,
	val missionType: String,
	val rewardTc: Int,
	val dueAt: Instant?,
	val evidenceRequired: Boolean,
	val sortOrder: Int,
	val status: String,
)

data class SubmitMissionRequest(
	val description: String? = null,
)

data class ReviewSubmissionRequest(
	@field:NotBlank
	val status: String,
	val reviewerNotes: String? = null,
)

data class SubmissionResponse(
	val id: String,
	val missionId: String,
	val userId: String,
	val description: String?,
	val status: String,
	val reviewerNotes: String?,
	val reviewedAt: Instant?,
	val evidenceCount: Long,
	val createdAt: Instant,
)

data class EvidenceUploadRequest(
	@field:NotBlank
	val contentType: String,
	@field:Min(1)
	val sizeBytes: Long,
)

data class EvidenceUploadResponse(
	val evidenceId: String,
	val storageKey: String,
	val uploadUrl: String,
	val expiresAt: Instant,
)

data class EvidenceFileResponse(
	val id: String,
	val storageKey: String,
	val contentType: String,
	val sizeBytes: Long,
	val createdAt: Instant,
)
