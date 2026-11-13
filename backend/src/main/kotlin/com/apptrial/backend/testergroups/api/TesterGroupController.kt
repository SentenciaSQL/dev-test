package com.apptrial.backend.testergroups.api

import com.apptrial.backend.shared.web.SecurityUtils
import com.apptrial.backend.testergroups.service.TesterGroupService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

@RestController
@RequestMapping("/api/v1")
class TesterGroupController(
	private val testerGroupService: TesterGroupService,
) {
	@GetMapping("/campaigns/{campaignId}/groups")
	fun listGroups(@PathVariable campaignId: UUID): List<CampaignGroupResponse> =
		testerGroupService.listCampaignGroups(campaignId, SecurityUtils.currentUser())

	@PostMapping("/campaigns/{campaignId}/join")
	@ResponseStatus(HttpStatus.CREATED)
	fun joinCampaign(@PathVariable campaignId: UUID): CampaignGroupResponse =
		testerGroupService.joinCampaign(campaignId, SecurityUtils.currentUser())

	@PostMapping("/campaigns/{campaignId}/groups/{groupId}/join")
	@ResponseStatus(HttpStatus.CREATED)
	fun joinGroup(
		@PathVariable campaignId: UUID,
		@PathVariable groupId: UUID,
	): CampaignGroupResponse =
		testerGroupService.joinGroup(campaignId, groupId, SecurityUtils.currentUser())

	@GetMapping("/me/groups")
	fun myGroups(): List<CampaignGroupResponse> =
		testerGroupService.listMyMemberships(SecurityUtils.currentUser().id)

	@PatchMapping("/group-members/{memberId}")
	fun updateMemberStatus(
		@PathVariable memberId: UUID,
		@Valid @RequestBody body: UpdateMemberStatusRequest,
	): GroupMemberResponse =
		testerGroupService.updateMemberStatus(
			memberId,
			SecurityUtils.currentUser(),
			body.status,
		)
}
