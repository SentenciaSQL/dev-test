package com.apptrial.backend.users.domain

import jakarta.persistence.CollectionTable
import jakarta.persistence.Column
import jakarta.persistence.ElementCollection
import jakarta.persistence.Entity
import jakarta.persistence.FetchType
import jakarta.persistence.Id
import jakarta.persistence.JoinColumn
import jakarta.persistence.Table
import org.hibernate.annotations.JdbcTypeCode
import org.hibernate.type.SqlTypes
import java.math.BigDecimal
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "users")
class UserEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(nullable = false, unique = true)
	var email: String,
	@Column(name = "password_hash")
	var passwordHash: String? = null,
	@Column(name = "display_name", nullable = false)
	var displayName: String,
	@Column(name = "photo_url")
	var photoUrl: String? = null,
	@JdbcTypeCode(SqlTypes.CHAR)
	@Column(name = "country_code", length = 2, columnDefinition = "bpchar(2)")
	var countryCode: String? = null,
	@Column(nullable = false)
	var locale: String = "en",
	@Column(name = "email_verified_at")
	var emailVerifiedAt: Instant? = null,
	@Column(nullable = false)
	var status: String = "ACTIVE",
	@Column(name = "reputation_score", nullable = false)
	var reputationScore: BigDecimal = BigDecimal.ZERO,
	@JdbcTypeCode(SqlTypes.JSON)
	@Column(name = "notification_prefs", nullable = false, columnDefinition = "jsonb")
	var notificationPrefs: Map<String, Any?> = emptyMap(),
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
	@Column(name = "updated_at", nullable = false)
	var updatedAt: Instant = Instant.now(),
) {
	@ElementCollection(fetch = FetchType.EAGER)
	@CollectionTable(name = "user_roles", joinColumns = [JoinColumn(name = "user_id")])
	@Column(name = "role")
	var roles: MutableSet<String> = mutableSetOf()
}

@Entity
@Table(name = "user_devices")
class UserDeviceEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(name = "user_id", nullable = false)
	var userId: UUID,
	@Column(name = "device_fingerprint", nullable = false)
	var deviceFingerprint: String,
	var model: String? = null,
	var manufacturer: String? = null,
	@Column(name = "android_version", nullable = false)
	var androidVersion: String,
	@Column(name = "sdk_int")
	var sdkInt: Int? = null,
	@Column(name = "is_primary", nullable = false)
	var primary: Boolean = false,
	@Column(name = "last_seen_at")
	var lastSeenAt: Instant? = null,
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
	@Column(name = "updated_at", nullable = false)
	var updatedAt: Instant = Instant.now(),
)

@Entity
@Table(name = "tester_profiles")
class TesterProfileEntity(
	@Id
	@Column(name = "user_id")
	var userId: UUID,
	@Column(name = "campaigns_completed", nullable = false)
	var campaignsCompleted: Int = 0,
	@Column(name = "campaigns_dropped", nullable = false)
	var campaignsDropped: Int = 0,
	var bio: String? = null,
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
	@Column(name = "updated_at", nullable = false)
	var updatedAt: Instant = Instant.now(),
)
