package com.apptrial.backend.feedback.domain

import org.springframework.data.jpa.repository.JpaRepository
import java.util.UUID

interface FeedbackReportRepository : JpaRepository<FeedbackReportEntity, UUID> {
	fun findAllByCampaignIdOrderByCreatedAtDesc(campaignId: UUID): List<FeedbackReportEntity>
	fun findAllByUserIdOrderByCreatedAtDesc(userId: UUID): List<FeedbackReportEntity>
}
