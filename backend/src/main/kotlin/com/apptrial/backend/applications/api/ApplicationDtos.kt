package com.apptrial.backend.applications.api

import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Pattern
import jakarta.validation.constraints.Size
import java.time.Instant

data class CreateApplicationRequest(
	@field:NotBlank @field:Size(max = 160)
	val name: String,
	@field:Size(max = 4000)
	val description: String? = null,
	@field:NotBlank
	@field:Pattern(
		regexp = "^[a-zA-Z][a-zA-Z0-9_]*(\\.[a-zA-Z][a-zA-Z0-9_]*)+$",
		message = "Invalid Android package name",
	)
	val packageName: String,
	val iconUrl: String? = null,
	@field:Size(max = 64)
	val category: String? = null,
	@field:Size(max = 64)
	val currentVersion: String? = null,
	val playStoreUrl: String? = null,
	val closedTestingUrl: String? = null,
	val instructions: String? = null,
	val screenshotUrls: List<String> = emptyList(),
)

data class UpdateApplicationRequest(
	@field:Size(max = 160)
	val name: String? = null,
	@field:Size(max = 4000)
	val description: String? = null,
	val iconUrl: String? = null,
	@field:Size(max = 64)
	val category: String? = null,
	@field:Size(max = 64)
	val currentVersion: String? = null,
	val playStoreUrl: String? = null,
	val closedTestingUrl: String? = null,
	val instructions: String? = null,
	val status: String? = null,
	val screenshotUrls: List<String>? = null,
)

data class ApplicationResponse(
	val id: String,
	val name: String,
	val description: String?,
	val packageName: String,
	val iconUrl: String?,
	val category: String?,
	val currentVersion: String?,
	val playStoreUrl: String?,
	val closedTestingUrl: String?,
	val instructions: String?,
	val status: String,
	val screenshotUrls: List<String>,
	val createdAt: Instant,
	val updatedAt: Instant,
)
