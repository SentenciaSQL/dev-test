package com.apptrial.backend.campaigns.api

import com.apptrial.backend.campaigns.domain.CampaignRepository
import com.apptrial.backend.shared.error.ForbiddenException
import com.apptrial.backend.shared.error.NotFoundException
import com.apptrial.backend.shared.sse.CampaignEventHub
import com.apptrial.backend.shared.web.SecurityUtils
import org.springframework.http.MediaType
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter
import java.util.UUID

@RestController
@RequestMapping("/api/v1/campaigns")
class CampaignSseController(
	private val campaignRepository: CampaignRepository,
	private val campaignEventHub: CampaignEventHub,
) {
	@GetMapping("/{campaignId}/events", produces = [MediaType.TEXT_EVENT_STREAM_VALUE])
	fun events(@PathVariable campaignId: UUID): SseEmitter {
		val principal = SecurityUtils.currentUser()
		val campaign = campaignRepository.findById(campaignId)
			.orElseThrow { NotFoundException("Campaign not found") }
		val allowed = campaign.createdByUserId == principal.id ||
			"ADMIN" in principal.roles ||
			"TESTER" in principal.roles
		if (!allowed) throw ForbiddenException()
		return campaignEventHub.subscribe(campaignId)
	}
}
