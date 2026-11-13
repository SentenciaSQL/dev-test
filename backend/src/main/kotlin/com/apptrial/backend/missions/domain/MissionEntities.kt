package com.apptrial.backend.missions.domain

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "campaign_missions")
class CampaignMissionEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(name = "campaign_id", nullable = false)
	var campaignId: UUID,
	@Column(nullable = false)
	var title: String,
	@Column(columnDefinition = "text")
	var description: String? = null,
	@Column(columnDefinition = "text")
	var instructions: String? = null,
	@Column(name = "mission_type", nullable = false)
	var missionType: String,
	@Column(name = "reward_tc", nullable = false)
	var rewardTc: Int = 0,
	@Column(name = "due_at")
	var dueAt: Instant? = null,
	@Column(name = "evidence_required", nullable = false)
	var evidenceRequired: Boolean = true,
	@Column(name = "sort_order", nullable = false)
	var sortOrder: Int = 0,
	@Column(nullable = false)
	var status: String = "ACTIVE",
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
	@Column(name = "updated_at", nullable = false)
	var updatedAt: Instant = Instant.now(),
)

@Entity
@Table(name = "mission_submissions")
class MissionSubmissionEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(name = "mission_id", nullable = false)
	var missionId: UUID,
	@Column(name = "user_id", nullable = false)
	var userId: UUID,
	@Column(columnDefinition = "text")
	var description: String? = null,
	@Column(nullable = false)
	var status: String = "PENDING",
	@Column(name = "reviewer_notes", columnDefinition = "text")
	var reviewerNotes: String? = null,
	@Column(name = "reviewed_by")
	var reviewedBy: UUID? = null,
	@Column(name = "reviewed_at")
	var reviewedAt: Instant? = null,
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
	@Column(name = "updated_at", nullable = false)
	var updatedAt: Instant = Instant.now(),
)
