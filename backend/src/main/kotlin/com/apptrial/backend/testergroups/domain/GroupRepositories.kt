package com.apptrial.backend.testergroups.domain

import org.springframework.data.jpa.repository.JpaRepository
import java.util.UUID

interface CampaignGroupRepository : JpaRepository<CampaignGroupEntity, UUID> {
	fun findAllByCampaignIdOrderByCreatedAtAsc(campaignId: UUID): List<CampaignGroupEntity>
	fun findByIdAndCampaignId(id: UUID, campaignId: UUID): CampaignGroupEntity?
	fun countByCampaignId(campaignId: UUID): Long
}

interface GroupMemberRepository : JpaRepository<GroupMemberEntity, UUID> {
	fun findAllByGroupIdOrderByCreatedAtAsc(groupId: UUID): List<GroupMemberEntity>
	fun findAllByUserIdOrderByCreatedAtDesc(userId: UUID): List<GroupMemberEntity>
	fun findByIdAndUserId(id: UUID, userId: UUID): GroupMemberEntity?
	fun findByGroupIdAndUserId(groupId: UUID, userId: UUID): GroupMemberEntity?
	fun existsByGroupIdAndUserId(groupId: UUID, userId: UUID): Boolean
	fun countByGroupIdAndStatusIn(groupId: UUID, statuses: Collection<String>): Long

	fun findAllByGroupIdIn(groupIds: Collection<UUID>): List<GroupMemberEntity>
}
