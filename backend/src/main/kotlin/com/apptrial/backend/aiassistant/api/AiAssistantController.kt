package com.apptrial.backend.aiassistant.api

import com.apptrial.backend.aiassistant.service.AiAssistantService
import com.apptrial.backend.aiassistant.service.AiCampaignInsights
import com.apptrial.backend.shared.web.SecurityUtils
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

@RestController
@RequestMapping("/api/v1/ai")
class AiAssistantController(
	private val aiAssistantService: AiAssistantService,
) {
	@GetMapping("/campaigns/{campaignId}/insights")
	fun insights(@PathVariable campaignId: UUID): AiCampaignInsights =
		aiAssistantService.campaignInsights(campaignId, SecurityUtils.currentUser())
}
