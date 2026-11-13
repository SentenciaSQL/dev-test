package com.apptrial.backend.testergroups.service

import com.apptrial.backend.campaigns.domain.CampaignEntity
import com.apptrial.backend.campaigns.domain.CampaignRepository
import com.apptrial.backend.shared.config.AppProperties
import com.apptrial.backend.shared.error.ConflictException
import com.apptrial.backend.shared.error.ForbiddenException
import com.apptrial.backend.shared.error.NotFoundException
import com.apptrial.backend.shared.error.ValidationApiException
import com.apptrial.backend.shared.security.UserPrincipal
import com.apptrial.backend.testergroups.api.CampaignGroupResponse
import com.apptrial.backend.testergroups.api.GroupMemberResponse
import com.apptrial.backend.testergroups.domain.CampaignGroupEntity
import com.apptrial.backend.testergroups.domain.CampaignGroupRepository
import com.apptrial.backend.testergroups.domain.GroupMemberEntity
import com.apptrial.backend.testergroups.domain.GroupMemberRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

@Service
class TesterGroupService(
	private val campaignRepository: CampaignRepository,
	private val groupRepository: CampaignGroupRepository,
	private val memberRepository: GroupMemberRepository,
	private val props: AppProperties,
) {
	companion object {
		/** Seats that count toward capacity. */
		val OCCUPYING_STATUSES = setOf("INVITED", "ACCEPTED", "CONFIRMED", "ACTIVE")
		private val joinableCampaignStatuses = setOf("RECRUITING", "PUBLISHED")
		private val allowedMemberTransitions = mapOf(
			"ACCEPTED" to setOf("CONFIRMED", "DROPPED"),
			"CONFIRMED" to setOf("ACTIVE", "DROPPED"),
			"ACTIVE" to setOf("DROPPED", "COMPLETED"),
			"INVITED" to setOf("ACCEPTED", "DROPPED"),
		)
	}

	@Transactional
	fun createGroupsForCampaign(campaign: CampaignEntity) {
		if (groupRepository.countByCampaignId(campaign.id) > 0) {
			return
		}
		val sizes = GroupSizing.split(
			targetTesters = campaign.targetTesters,
			defaultSize = props.credits.defaultGroupSize,
			minSize = props.credits.minGroupSize,
		)
		sizes.forEachIndexed { index, size ->
			groupRepository.save(
				CampaignGroupEntity(
					campaignId = campaign.id,
					name = "Grupo ${index + 1}",
					targetSize = size,
					startsAt = campaign.startsAt,
					endsAt = campaign.endsAt,
					status = "RECRUITING",
				),
			)
		}
	}

	@Transactional
	fun cancelGroupsForCampaign(campaignId: UUID) {
		val now = Instant.now()
		groupRepository.findAllByCampaignIdOrderByCreatedAtAsc(campaignId).forEach { group ->
			if (group.status != "CANCELLED" && group.status != "COMPLETED") {
				group.status = "CANCELLED"
				group.updatedAt = now
				groupRepository.save(group)
			}
			memberRepository.findAllByGroupIdOrderByCreatedAtAsc(group.id)
				.filter { it.status in OCCUPYING_STATUSES }
				.forEach { member ->
					member.status = "DROPPED"
					member.droppedAt = now
					member.updatedAt = now
					memberRepository.save(member)
				}
		}
	}

	@Transactional(readOnly = true)
	fun listCampaignGroups(campaignId: UUID, viewer: UserPrincipal): List<CampaignGroupResponse> {
		val campaign = campaignRepository.findById(campaignId)
			.orElseThrow { NotFoundException("Campaign not found") }
		val isOwner = campaign.createdByUserId == viewer.id || "ADMIN" in viewer.roles
		val isPublic = campaign.status in joinableCampaignStatuses ||
			campaign.status == "ACTIVE" ||
			campaign.status == "FULL"
		if (!isOwner && !isPublic) {
			throw ForbiddenException("Campaign groups are not available")
		}
		val groups = groupRepository.findAllByCampaignIdOrderByCreatedAtAsc(campaignId)
		return groups.map { toGroupResponse(it, campaign, viewer.id, includeMembers = isOwner) }
	}

	@Transactional(readOnly = true)
	fun listMyMemberships(userId: UUID): List<CampaignGroupResponse> {
		val memberships = memberRepository.findAllByUserIdOrderByCreatedAtDesc(userId)
		return memberships.mapNotNull { membership ->
			val group = groupRepository.findById(membership.groupId).orElse(null) ?: return@mapNotNull null
			val campaign = campaignRepository.findById(group.campaignId).orElse(null) ?: return@mapNotNull null
			toGroupResponse(group, campaign, userId, includeMembers = false)
		}
	}

	@Transactional
	fun joinCampaign(campaignId: UUID, principal: UserPrincipal): CampaignGroupResponse {
		requireTester(principal)
		val campaign = campaignRepository.findById(campaignId)
			.orElseThrow { NotFoundException("Campaign not found") }
		if (campaign.status !in joinableCampaignStatuses) {
			throw ConflictException("Campaign is not recruiting")
		}
		if (campaign.createdByUserId == principal.id) {
			throw ConflictException("Campaign owner cannot join as tester")
		}

		val groups = groupRepository.findAllByCampaignIdOrderByCreatedAtAsc(campaignId)
		if (groups.isEmpty()) {
			throw ConflictException("Campaign has no groups yet")
		}

		val alreadyInCampaign = groups.any { group ->
			val existing = memberRepository.findByGroupIdAndUserId(group.id, principal.id)
			existing != null && existing.status in OCCUPYING_STATUSES
		}
		if (alreadyInCampaign) {
			throw ConflictException("Already participating in this campaign")
		}

		val target = groups.firstOrNull { group ->
			group.status == "RECRUITING" && openSeats(group) > 0
		} ?: throw ConflictException("No open seats available")

		val now = Instant.now()
		val member = memberRepository.save(
			GroupMemberEntity(
				groupId = target.id,
				userId = principal.id,
				status = "ACCEPTED",
				invitedAt = now,
				acceptedAt = now,
			),
		)

		refreshGroupAndCampaignStatus(target, campaign)
		return toGroupResponse(
			groupRepository.findById(target.id).orElse(target),
			campaignRepository.findById(campaign.id).orElse(campaign),
			principal.id,
			includeMembers = false,
			forcedMembership = member,
		)
	}

	@Transactional
	fun joinGroup(campaignId: UUID, groupId: UUID, principal: UserPrincipal): CampaignGroupResponse {
		requireTester(principal)
		val campaign = campaignRepository.findById(campaignId)
			.orElseThrow { NotFoundException("Campaign not found") }
		if (campaign.status !in joinableCampaignStatuses) {
			throw ConflictException("Campaign is not recruiting")
		}
		val group = groupRepository.findByIdAndCampaignId(groupId, campaignId)
			?: throw NotFoundException("Group not found")
		if (group.status != "RECRUITING") {
			throw ConflictException("Group is not recruiting")
		}
		if (openSeats(group) <= 0) {
			throw ConflictException("Group is full")
		}
		if (campaign.createdByUserId == principal.id) {
			throw ConflictException("Campaign owner cannot join as tester")
		}

		val existingElsewhere = groupRepository.findAllByCampaignIdOrderByCreatedAtAsc(campaignId)
			.any { g ->
				val m = memberRepository.findByGroupIdAndUserId(g.id, principal.id)
				m != null && m.status in OCCUPYING_STATUSES
			}
		if (existingElsewhere) {
			throw ConflictException("Already participating in this campaign")
		}

		val now = Instant.now()
		val member = memberRepository.save(
			GroupMemberEntity(
				groupId = group.id,
				userId = principal.id,
				status = "ACCEPTED",
				invitedAt = now,
				acceptedAt = now,
			),
		)
		refreshGroupAndCampaignStatus(group, campaign)
		return toGroupResponse(
			groupRepository.findById(group.id).orElse(group),
			campaignRepository.findById(campaign.id).orElse(campaign),
			principal.id,
			includeMembers = false,
			forcedMembership = member,
		)
	}

	@Transactional
	fun updateMemberStatus(
		memberId: UUID,
		principal: UserPrincipal,
		requestedStatus: String,
	): GroupMemberResponse {
		val status = requestedStatus.uppercase()
		val member = memberRepository.findById(memberId)
			.orElseThrow { NotFoundException("Membership not found") }
		val group = groupRepository.findById(member.groupId)
			.orElseThrow { NotFoundException("Group not found") }
		val campaign = campaignRepository.findById(group.campaignId)
			.orElseThrow { NotFoundException("Campaign not found") }

		val isSelf = member.userId == principal.id
		val isOwner = campaign.createdByUserId == principal.id || "ADMIN" in principal.roles
		if (!isSelf && !isOwner) {
			throw ForbiddenException("Not allowed to update this membership")
		}

		val allowed = allowedMemberTransitions[member.status].orEmpty()
		if (status !in allowed) {
			throw ValidationApiException(
				"Invalid status transition",
				listOf("${member.status} → $status is not allowed"),
			)
		}

		val now = Instant.now()
		when (status) {
			"ACCEPTED" -> member.acceptedAt = now
			"CONFIRMED" -> member.confirmedAt = now
			"ACTIVE" -> member.activeAt = now
			"DROPPED" -> member.droppedAt = now
			"COMPLETED" -> member.completedAt = now
		}
		member.status = status
		member.updatedAt = now
		memberRepository.save(member)

		if (status == "DROPPED" && group.status == "READY") {
			group.status = "RECRUITING"
			group.updatedAt = now
			groupRepository.save(group)
			if (campaign.status == "FULL") {
				campaign.status = "RECRUITING"
				campaign.updatedAt = now
				campaignRepository.save(campaign)
			}
		} else {
			refreshGroupAndCampaignStatus(group, campaign)
		}

		return toMemberResponse(member)
	}

	private fun refreshGroupAndCampaignStatus(group: CampaignGroupEntity, campaign: CampaignEntity) {
		val occupied = memberRepository.countByGroupIdAndStatusIn(group.id, OCCUPYING_STATUSES).toInt()
		val now = Instant.now()
		if (group.status == "RECRUITING" && occupied >= group.targetSize) {
			group.status = "READY"
			group.updatedAt = now
			groupRepository.save(group)
		}

		val allGroups = groupRepository.findAllByCampaignIdOrderByCreatedAtAsc(campaign.id)
		val totalOccupied = allGroups.sumOf { g ->
			memberRepository.countByGroupIdAndStatusIn(g.id, OCCUPYING_STATUSES).toInt()
		}
		if (campaign.status in joinableCampaignStatuses && totalOccupied >= campaign.targetTesters) {
			campaign.status = "FULL"
			campaign.updatedAt = now
			campaignRepository.save(campaign)
		}
	}

	private fun openSeats(group: CampaignGroupEntity): Int {
		val occupied = memberRepository.countByGroupIdAndStatusIn(group.id, OCCUPYING_STATUSES).toInt()
		return (group.targetSize - occupied).coerceAtLeast(0)
	}

	private fun toGroupResponse(
		group: CampaignGroupEntity,
		campaign: CampaignEntity,
		viewerId: UUID,
		includeMembers: Boolean,
		forcedMembership: GroupMemberEntity? = null,
	): CampaignGroupResponse {
		val occupied = memberRepository.countByGroupIdAndStatusIn(group.id, OCCUPYING_STATUSES).toInt()
		val members = if (includeMembers) {
			memberRepository.findAllByGroupIdOrderByCreatedAtAsc(group.id).map { toMemberResponse(it) }
		} else {
			emptyList()
		}
		val mine = forcedMembership
			?: memberRepository.findByGroupIdAndUserId(group.id, viewerId)
		return CampaignGroupResponse(
			id = group.id.toString(),
			campaignId = campaign.id.toString(),
			campaignName = campaign.name,
			name = group.name,
			targetSize = group.targetSize,
			occupiedSeats = occupied,
			openSeats = (group.targetSize - occupied).coerceAtLeast(0),
			status = group.status,
			startsAt = group.startsAt,
			endsAt = group.endsAt,
			members = members,
			myMembershipId = mine?.id?.toString(),
			myMembershipStatus = mine?.status,
		)
	}

	private fun toMemberResponse(member: GroupMemberEntity) = GroupMemberResponse(
		id = member.id.toString(),
		userId = member.userId.toString(),
		status = member.status,
		invitedAt = member.invitedAt,
		acceptedAt = member.acceptedAt,
		confirmedAt = member.confirmedAt,
		activeAt = member.activeAt,
		droppedAt = member.droppedAt,
		completedAt = member.completedAt,
	)

	private fun requireTester(principal: UserPrincipal) {
		if ("TESTER" !in principal.roles && "ADMIN" !in principal.roles) {
			throw ForbiddenException("Tester role required")
		}
	}
}
