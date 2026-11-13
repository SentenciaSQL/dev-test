package com.apptrial.backend.identity.domain

import org.springframework.data.jpa.repository.JpaRepository
import java.util.UUID

interface RefreshTokenRepository : JpaRepository<RefreshTokenEntity, UUID> {
	fun findByTokenHash(tokenHash: String): RefreshTokenEntity?
}

interface EmailVerificationTokenRepository : JpaRepository<EmailVerificationTokenEntity, UUID> {
	fun findByTokenHash(tokenHash: String): EmailVerificationTokenEntity?
}

interface PasswordResetTokenRepository : JpaRepository<PasswordResetTokenEntity, UUID> {
	fun findByTokenHash(tokenHash: String): PasswordResetTokenEntity?
}
