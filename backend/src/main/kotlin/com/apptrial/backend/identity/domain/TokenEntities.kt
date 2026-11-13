package com.apptrial.backend.identity.domain

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "refresh_tokens")
class RefreshTokenEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(name = "user_id", nullable = false)
	var userId: UUID,
	@Column(name = "token_hash", nullable = false, unique = true)
	var tokenHash: String,
	@Column(name = "expires_at", nullable = false)
	var expiresAt: Instant,
	@Column(name = "revoked_at")
	var revokedAt: Instant? = null,
	@Column(name = "replaced_by_id")
	var replacedById: UUID? = null,
	@Column(name = "user_agent", columnDefinition = "text")
	var userAgent: String? = null,
	@Column(name = "ip_address")
	var ipAddress: String? = null,
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
)

@Entity
@Table(name = "email_verification_tokens")
class EmailVerificationTokenEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(name = "user_id", nullable = false)
	var userId: UUID,
	@Column(name = "token_hash", nullable = false, unique = true)
	var tokenHash: String,
	@Column(name = "expires_at", nullable = false)
	var expiresAt: Instant,
	@Column(name = "used_at")
	var usedAt: Instant? = null,
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
)

@Entity
@Table(name = "password_reset_tokens")
class PasswordResetTokenEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(name = "user_id", nullable = false)
	var userId: UUID,
	@Column(name = "token_hash", nullable = false, unique = true)
	var tokenHash: String,
	@Column(name = "expires_at", nullable = false)
	var expiresAt: Instant,
	@Column(name = "used_at")
	var usedAt: Instant? = null,
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
)
