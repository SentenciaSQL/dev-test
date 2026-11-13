package com.apptrial.backend.identity.api

import com.apptrial.backend.users.api.UserResponse
import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size

data class RegisterRequest(
	@field:Email @field:NotBlank
	val email: String,
	@field:NotBlank @field:Size(min = 8, max = 128)
	val password: String,
	@field:NotBlank @field:Size(min = 2, max = 120)
	val displayName: String,
	val roles: Set<String> = setOf("TESTER"),
	val countryCode: String? = null,
	val locale: String? = null,
)

data class LoginRequest(
	@field:Email @field:NotBlank
	val email: String,
	@field:NotBlank
	val password: String,
)

data class RefreshRequest(
	@field:NotBlank
	val refreshToken: String,
)

data class LogoutRequest(
	@field:NotBlank
	val refreshToken: String,
)

data class VerifyEmailRequest(
	@field:NotBlank
	val token: String,
)

data class ForgotPasswordRequest(
	@field:Email @field:NotBlank
	val email: String,
)

data class ResetPasswordRequest(
	@field:NotBlank
	val token: String,
	@field:NotBlank @field:Size(min = 8, max = 128)
	val newPassword: String,
)

data class AuthTokensResponse(
	val accessToken: String,
	val refreshToken: String,
	val expiresIn: Long,
	val tokenType: String = "Bearer",
	val user: UserResponse,
)

data class RegisterResponse(
	val userId: String,
	val email: String,
	val roles: Set<String>,
	val message: String = "Registered. Verify your email to activate full access.",
)
