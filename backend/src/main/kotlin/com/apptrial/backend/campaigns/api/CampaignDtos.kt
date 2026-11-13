package com.apptrial.backend.campaigns.api

import jakarta.validation.constraints.Max
import jakarta.validation.constraints.Min
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull
import jakarta.validation.constraints.Size
import java.time.Instant

data class CreateCampaignRequest(
	@field:NotNull
	val applicationId: String,
	@field:NotBlank @field:Size(max = 160)
	val name: String,
	@field:Size(max = 4000)
	val description: String? = null,
	val testType: String = "CLOSED",
	@field:Min(7) @field:Max(90)
	val durationDays: Int,
	val startsAt: Instant? = null,
	@field:Min(12) @field:Max(500)
	val targetTesters: Int = 15,
	val allowedCountries: List<String> = emptyList(),
	val minAndroidSdk: Int? = null,
	val maxAndroidSdk: Int? = null,
	val instructions: String? = null,
)

data class UpdateCampaignRequest(
	@field:Size(max = 160)
	val name: String? = null,
	@field:Size(max = 4000)
	val description: String? = null,
	val testType: String? = null,
	@field:Min(7) @field:Max(90)
	val durationDays: Int? = null,
	val startsAt: Instant? = null,
	@field:Min(12) @field:Max(500)
	val targetTesters: Int? = null,
	val allowedCountries: List<String>? = null,
	val minAndroidSdk: Int? = null,
	val maxAndroidSdk: Int? = null,
	val instructions: String? = null,
)

data class CampaignResponse(
	val id: String,
	val applicationId: String,
	val applicationName: String?,
	val name: String,
	val description: String?,
	val testType: String,
	val durationDays: Int,
	val startsAt: Instant?,
	val endsAt: Instant?,
	val targetTesters: Int,
	val allowedCountries: List<String>,
	val minAndroidSdk: Int?,
	val maxAndroidSdk: Int?,
	val instructions: String?,
	val status: String,
	val costPerTesterTc: Int,
	val totalCostTc: Int,
	val createdAt: Instant,
	val updatedAt: Instant,
)
