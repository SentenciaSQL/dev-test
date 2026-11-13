package com.apptrial.backend.users.api

import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size
import java.math.BigDecimal
import java.time.Instant

data class UserResponse(
	val id: String,
	val email: String,
	val displayName: String,
	val photoUrl: String?,
	val countryCode: String?,
	val locale: String,
	val emailVerified: Boolean,
	val roles: Set<String>,
	val reputationScore: BigDecimal,
	val notificationPreferences: Map<String, Any?>,
	val createdAt: Instant,
)

data class UpdateProfileRequest(
	@field:Size(min = 2, max = 120)
	val displayName: String? = null,
	val photoUrl: String? = null,
	@field:Size(min = 2, max = 2)
	val countryCode: String? = null,
	@field:Size(min = 2, max = 16)
	val locale: String? = null,
	val notificationPreferences: Map<String, Any?>? = null,
)

data class DeviceRequest(
	@field:NotBlank @field:Size(max = 128)
	val deviceFingerprint: String,
	val model: String? = null,
	val manufacturer: String? = null,
	@field:NotBlank @field:Size(max = 32)
	val androidVersion: String,
	val sdkInt: Int? = null,
	val primary: Boolean = false,
)

data class DeviceResponse(
	val id: String,
	val deviceFingerprint: String,
	val model: String?,
	val manufacturer: String?,
	val androidVersion: String,
	val sdkInt: Int?,
	val primary: Boolean,
	val lastSeenAt: Instant?,
	val createdAt: Instant,
)
