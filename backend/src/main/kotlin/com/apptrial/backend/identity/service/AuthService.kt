package com.apptrial.backend.identity.service

import com.apptrial.backend.credits.service.CreditWalletService
import com.apptrial.backend.identity.api.AuthTokensResponse
import com.apptrial.backend.identity.api.LoginRequest
import com.apptrial.backend.identity.api.RegisterRequest
import com.apptrial.backend.identity.api.RegisterResponse
import com.apptrial.backend.identity.api.ResetPasswordRequest
import com.apptrial.backend.identity.domain.EmailVerificationTokenEntity
import com.apptrial.backend.identity.domain.EmailVerificationTokenRepository
import com.apptrial.backend.identity.domain.PasswordResetTokenEntity
import com.apptrial.backend.identity.domain.PasswordResetTokenRepository
import com.apptrial.backend.identity.domain.RefreshTokenEntity
import com.apptrial.backend.identity.domain.RefreshTokenRepository
import com.apptrial.backend.shared.config.AppProperties
import com.apptrial.backend.shared.error.ConflictException
import com.apptrial.backend.shared.error.UnauthorizedException
import com.apptrial.backend.shared.error.ValidationApiException
import com.apptrial.backend.shared.security.JwtService
import com.apptrial.backend.users.domain.TesterProfileEntity
import com.apptrial.backend.users.domain.TesterProfileRepository
import com.apptrial.backend.users.domain.UserEntity
import com.apptrial.backend.users.domain.UserRepository
import com.apptrial.backend.users.service.UserMapper
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.time.temporal.ChronoUnit

@Service
class AuthService(
	private val userRepository: UserRepository,
	private val refreshTokenRepository: RefreshTokenRepository,
	private val emailVerificationTokenRepository: EmailVerificationTokenRepository,
	private val passwordResetTokenRepository: PasswordResetTokenRepository,
	private val testerProfileRepository: TesterProfileRepository,
	private val creditWalletService: CreditWalletService,
	private val passwordEncoder: PasswordEncoder,
	private val jwtService: JwtService,
	private val mailNotifier: MailNotifier,
	private val props: AppProperties,
) {
	private val allowedRoles = setOf("DEVELOPER", "TESTER")

	@Transactional
	fun register(request: RegisterRequest): RegisterResponse {
		val email = request.email.trim().lowercase()
		if (userRepository.existsByEmailIgnoreCase(email)) {
			throw ConflictException("Email already registered")
		}
		val roles = request.roles.map { it.uppercase() }.toMutableSet()
		if (roles.isEmpty()) roles += "TESTER"
		if (!allowedRoles.containsAll(roles) || roles.any { it == "ADMIN" }) {
			throw ValidationApiException("Invalid roles", listOf("Allowed: DEVELOPER, TESTER"))
		}

		val user = UserEntity(
			email = email,
			passwordHash = passwordEncoder.encode(request.password),
			displayName = request.displayName.trim(),
			countryCode = request.countryCode?.uppercase(),
			locale = request.locale ?: "en",
		)
		user.roles = roles
		userRepository.save(user)

		if ("TESTER" in roles) {
			testerProfileRepository.save(TesterProfileEntity(userId = user.id))
		}
		creditWalletService.createWalletWithWelcomeGrant(user.id)
		issueEmailVerification(user)

		return RegisterResponse(
			userId = user.id.toString(),
			email = user.email,
			roles = user.roles,
		)
	}

	@Transactional
	fun login(request: LoginRequest, userAgent: String?, ip: String?): AuthTokensResponse {
		val user = userRepository.findByEmailIgnoreCase(request.email.trim())
			?: throw UnauthorizedException("Invalid credentials")
		if (user.status != "ACTIVE") throw UnauthorizedException("Account is not active")
		val hash = user.passwordHash ?: throw UnauthorizedException("Invalid credentials")
		if (!passwordEncoder.matches(request.password, hash)) {
			throw UnauthorizedException("Invalid credentials")
		}
		return issueSession(user, userAgent, ip)
	}

	@Transactional
	fun refresh(rawRefreshToken: String, userAgent: String?, ip: String?): AuthTokensResponse {
		val existing = refreshTokenRepository.findByTokenHash(TokenHashing.sha256(rawRefreshToken))
			?: throw UnauthorizedException("Invalid refresh token")
		if (existing.revokedAt != null || existing.expiresAt.isBefore(Instant.now())) {
			throw UnauthorizedException("Refresh token expired or revoked")
		}
		val user = userRepository.findById(existing.userId).orElseThrow { UnauthorizedException() }
		if (user.status != "ACTIVE") throw UnauthorizedException("Account is not active")

		existing.revokedAt = Instant.now()
		val tokens = issueSession(user, userAgent, ip)
		// mark rotation link after new token persisted inside issueSession — look up latest
		val newHash = TokenHashing.sha256(tokens.refreshToken)
		val replacement = refreshTokenRepository.findByTokenHash(newHash)
		existing.replacedById = replacement?.id
		refreshTokenRepository.save(existing)
		return tokens
	}

	@Transactional
	fun logout(rawRefreshToken: String) {
		val existing = refreshTokenRepository.findByTokenHash(TokenHashing.sha256(rawRefreshToken)) ?: return
		existing.revokedAt = Instant.now()
		refreshTokenRepository.save(existing)
	}

	@Transactional
	fun verifyEmail(rawToken: String) {
		val entity = emailVerificationTokenRepository.findByTokenHash(TokenHashing.sha256(rawToken))
			?: throw ValidationApiException("Invalid verification token")
		if (entity.usedAt != null || entity.expiresAt.isBefore(Instant.now())) {
			throw ValidationApiException("Verification token expired")
		}
		val user = userRepository.findById(entity.userId).orElseThrow()
		user.emailVerifiedAt = Instant.now()
		user.updatedAt = Instant.now()
		userRepository.save(user)
		entity.usedAt = Instant.now()
		emailVerificationTokenRepository.save(entity)
	}

	@Transactional
	fun forgotPassword(email: String) {
		val user = userRepository.findByEmailIgnoreCase(email.trim()) ?: return
		val raw = TokenHashing.generateRawToken()
		passwordResetTokenRepository.save(
			PasswordResetTokenEntity(
				userId = user.id,
				tokenHash = TokenHashing.sha256(raw),
				expiresAt = Instant.now().plus(1, ChronoUnit.HOURS),
			),
		)
		mailNotifier.sendPasswordReset(user.email, raw)
	}

	@Transactional
	fun resetPassword(request: ResetPasswordRequest) {
		val entity = passwordResetTokenRepository.findByTokenHash(TokenHashing.sha256(request.token))
			?: throw ValidationApiException("Invalid reset token")
		if (entity.usedAt != null || entity.expiresAt.isBefore(Instant.now())) {
			throw ValidationApiException("Reset token expired")
		}
		val user = userRepository.findById(entity.userId).orElseThrow()
		user.passwordHash = passwordEncoder.encode(request.newPassword)
		user.updatedAt = Instant.now()
		userRepository.save(user)
		entity.usedAt = Instant.now()
		passwordResetTokenRepository.save(entity)
	}

	private fun issueEmailVerification(user: UserEntity) {
		val raw = TokenHashing.generateRawToken()
		emailVerificationTokenRepository.save(
			EmailVerificationTokenEntity(
				userId = user.id,
				tokenHash = TokenHashing.sha256(raw),
				expiresAt = Instant.now().plus(2, ChronoUnit.DAYS),
			),
		)
		mailNotifier.sendEmailVerification(user.email, raw)
	}

	private fun issueSession(user: UserEntity, userAgent: String?, ip: String?): AuthTokensResponse {
		val access = jwtService.createAccessToken(user.id, user.email, user.roles)
		val rawRefresh = TokenHashing.generateRawToken()
		refreshTokenRepository.save(
			RefreshTokenEntity(
				userId = user.id,
				tokenHash = TokenHashing.sha256(rawRefresh),
				expiresAt = Instant.now().plus(props.security.refreshTokenDays, ChronoUnit.DAYS),
				userAgent = userAgent,
				ipAddress = ip,
			),
		)
		return AuthTokensResponse(
			accessToken = access,
			refreshToken = rawRefresh,
			expiresIn = jwtService.accessTokenTtlSeconds(),
			user = UserMapper.toResponse(user),
		)
	}
}
