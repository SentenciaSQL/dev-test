package com.apptrial.backend.feedback.api

import com.apptrial.backend.feedback.service.FeedbackService
import com.apptrial.backend.shared.web.SecurityUtils
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

@RestController
@RequestMapping("/api/v1")
class FeedbackController(
	private val feedbackService: FeedbackService,
) {
	@PostMapping("/campaigns/{campaignId}/feedback")
	@ResponseStatus(HttpStatus.CREATED)
	fun create(
		@PathVariable campaignId: UUID,
		@Valid @RequestBody body: CreateFeedbackRequest,
	): FeedbackResponse = feedbackService.create(campaignId, SecurityUtils.currentUser(), body)

	@GetMapping("/campaigns/{campaignId}/feedback")
	fun listCampaign(@PathVariable campaignId: UUID): List<FeedbackResponse> =
		feedbackService.listForCampaign(campaignId, SecurityUtils.currentUser())

	@GetMapping("/me/feedback")
	fun myFeedback(): List<FeedbackResponse> =
		feedbackService.listMine(SecurityUtils.currentUser().id)
}
