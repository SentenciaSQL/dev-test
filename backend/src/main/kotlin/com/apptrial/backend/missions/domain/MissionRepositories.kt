package com.apptrial.backend.missions.domain

import org.springframework.data.jpa.repository.JpaRepository
import java.util.UUID

interface CampaignMissionRepository : JpaRepository<CampaignMissionEntity, UUID> {
	fun findAllByCampaignIdOrderBySortOrderAsc(campaignId: UUID): List<CampaignMissionEntity>
	fun findByIdAndCampaignId(id: UUID, campaignId: UUID): CampaignMissionEntity?
}

interface MissionSubmissionRepository : JpaRepository<MissionSubmissionEntity, UUID> {
	fun findByMissionIdAndUserId(missionId: UUID, userId: UUID): MissionSubmissionEntity?
	fun findAllByMissionIdOrderByCreatedAtDesc(missionId: UUID): List<MissionSubmissionEntity>
	fun findAllByUserIdOrderByCreatedAtDesc(userId: UUID): List<MissionSubmissionEntity>
	fun findByIdAndUserId(id: UUID, userId: UUID): MissionSubmissionEntity?
}
