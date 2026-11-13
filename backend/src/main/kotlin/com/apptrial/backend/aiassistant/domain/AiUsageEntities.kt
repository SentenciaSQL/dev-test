package com.apptrial.backend.aiassistant.domain

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table
import org.springframework.data.jpa.repository.JpaRepository
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "ai_usage_logs")
class AiUsageLogEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(name = "user_id")
	var userId: UUID? = null,
	@Column(name = "campaign_id")
	var campaignId: UUID? = null,
	@Column(nullable = false)
	var mode: String,
	@Column(name = "input_chars", nullable = false)
	var inputChars: Int = 0,
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
)

interface AiUsageLogRepository : JpaRepository<AiUsageLogEntity, UUID>
