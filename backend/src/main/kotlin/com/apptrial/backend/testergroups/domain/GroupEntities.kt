package com.apptrial.backend.testergroups.domain

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "campaign_groups")
class CampaignGroupEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(name = "campaign_id", nullable = false)
	var campaignId: UUID,
	@Column(nullable = false)
	var name: String,
	@Column(name = "target_size", nullable = false)
	var targetSize: Int = 15,
	@Column(name = "starts_at")
	var startsAt: Instant? = null,
	@Column(name = "ends_at")
	var endsAt: Instant? = null,
	@Column(nullable = false)
	var status: String = "RECRUITING",
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
	@Column(name = "updated_at", nullable = false)
	var updatedAt: Instant = Instant.now(),
)

@Entity
@Table(name = "group_members")
class GroupMemberEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(name = "group_id", nullable = false)
	var groupId: UUID,
	@Column(name = "user_id", nullable = false)
	var userId: UUID,
	@Column(nullable = false)
	var status: String = "ACCEPTED",
	@Column(name = "invited_at", nullable = false)
	var invitedAt: Instant = Instant.now(),
	@Column(name = "accepted_at")
	var acceptedAt: Instant? = null,
	@Column(name = "confirmed_at")
	var confirmedAt: Instant? = null,
	@Column(name = "active_at")
	var activeAt: Instant? = null,
	@Column(name = "dropped_at")
	var droppedAt: Instant? = null,
	@Column(name = "completed_at")
	var completedAt: Instant? = null,
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
	@Column(name = "updated_at", nullable = false)
	var updatedAt: Instant = Instant.now(),
)
