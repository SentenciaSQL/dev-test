package com.apptrial.backend.campaigns.domain

import org.springframework.data.jpa.repository.JpaRepository
import java.util.UUID

interface CampaignRepository : JpaRepository<CampaignEntity, UUID> {
	fun findAllByCreatedByUserIdOrderByCreatedAtDesc(userId: UUID): List<CampaignEntity>
	fun findByIdAndCreatedByUserId(id: UUID, userId: UUID): CampaignEntity?
	fun countByCreatedByUserIdAndStatusNotIn(userId: UUID, statuses: Collection<String>): Long
	fun findAllByStatusInOrderByCreatedAtDesc(statuses: Collection<String>): List<CampaignEntity>
}
