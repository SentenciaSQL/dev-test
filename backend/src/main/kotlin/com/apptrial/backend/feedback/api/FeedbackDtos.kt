package com.apptrial.backend.feedback.api

import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size
import java.time.Instant

data class CreateFeedbackRequest(
	@field:NotBlank
	val reportType: String,
	@field:NotBlank @field:Size(max = 200)
	val title: String,
	@field:NotBlank @field:Size(max = 8000)
	val body: String,
	val severity: String? = null,
)

data class FeedbackResponse(
	val id: String,
	val campaignId: String,
	val userId: String,
	val reportType: String,
	val title: String,
	val body: String,
	val severity: String?,
	val status: String,
	val createdAt: Instant,
)
