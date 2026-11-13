package com.apptrial.backend.testergroups.api

import jakarta.validation.constraints.NotBlank
import java.time.Instant

data class GroupMemberResponse(
	val id: String,
	val userId: String,
	val status: String,
	val invitedAt: Instant,
	val acceptedAt: Instant?,
	val confirmedAt: Instant?,
	val activeAt: Instant?,
	val droppedAt: Instant?,
	val completedAt: Instant?,
)

data class CampaignGroupResponse(
	val id: String,
	val campaignId: String,
	val campaignName: String?,
	val name: String,
	val targetSize: Int,
	val occupiedSeats: Int,
	val openSeats: Int,
	val status: String,
	val startsAt: Instant?,
	val endsAt: Instant?,
	val members: List<GroupMemberResponse> = emptyList(),
	val myMembershipId: String? = null,
	val myMembershipStatus: String? = null,
)

data class UpdateMemberStatusRequest(
	@field:NotBlank
	val status: String,
)
