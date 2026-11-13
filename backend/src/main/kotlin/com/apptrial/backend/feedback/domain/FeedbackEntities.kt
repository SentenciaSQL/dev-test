package com.apptrial.backend.feedback.domain

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "feedback_reports")
class FeedbackReportEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(name = "campaign_id", nullable = false)
	var campaignId: UUID,
	@Column(name = "user_id", nullable = false)
	var userId: UUID,
	@Column(name = "report_type", nullable = false)
	var reportType: String,
	@Column(nullable = false)
	var title: String,
	@Column(nullable = false, columnDefinition = "text")
	var body: String,
	var severity: String? = null,
	@Column(nullable = false)
	var status: String = "OPEN",
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
	@Column(name = "updated_at", nullable = false)
	var updatedAt: Instant = Instant.now(),
)
