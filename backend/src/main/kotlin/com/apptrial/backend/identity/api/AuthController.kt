package com.apptrial.backend.identity.api

import com.apptrial.backend.identity.service.AuthService
import jakarta.servlet.http.HttpServletRequest
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/v1/auth")
class AuthController(
	private val authService: AuthService,
) {
	@PostMapping("/register")
	@ResponseStatus(HttpStatus.CREATED)
	fun register(@Valid @RequestBody body: RegisterRequest): RegisterResponse =
		authService.register(body)

	@PostMapping("/login")
	fun login(@Valid @RequestBody body: LoginRequest, request: HttpServletRequest): AuthTokensResponse =
		authService.login(body, request.getHeader("User-Agent"), request.remoteAddr)

	@PostMapping("/refresh")
	fun refresh(@Valid @RequestBody body: RefreshRequest, request: HttpServletRequest): AuthTokensResponse =
		authService.refresh(body.refreshToken, request.getHeader("User-Agent"), request.remoteAddr)

	@PostMapping("/logout")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	fun logout(@Valid @RequestBody body: LogoutRequest) {
		authService.logout(body.refreshToken)
	}

	@PostMapping("/verify-email")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	fun verifyEmail(@Valid @RequestBody body: VerifyEmailRequest) {
		authService.verifyEmail(body.token)
	}

	@PostMapping("/forgot-password")
	@ResponseStatus(HttpStatus.ACCEPTED)
	fun forgotPassword(@Valid @RequestBody body: ForgotPasswordRequest) {
		authService.forgotPassword(body.email)
	}

	@PostMapping("/reset-password")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	fun resetPassword(@Valid @RequestBody body: ResetPasswordRequest) {
		authService.resetPassword(body)
	}
}
