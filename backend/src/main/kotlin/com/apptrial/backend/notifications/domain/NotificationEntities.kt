package com.apptrial.backend.notifications.domain

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table
import org.hibernate.annotations.JdbcTypeCode
import org.hibernate.type.SqlTypes
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "notifications")
class NotificationEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(name = "user_id", nullable = false)
	var userId: UUID,
	@Column(name = "event_type", nullable = false)
	var eventType: String,
	@Column(nullable = false)
	var title: String,
	@Column(nullable = false, columnDefinition = "text")
	var body: String,
	@JdbcTypeCode(SqlTypes.JSON)
	@Column(nullable = false, columnDefinition = "jsonb")
	var payload: Map<String, Any?> = emptyMap(),
	@Column(name = "read_at")
	var readAt: Instant? = null,
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
)

@Entity
@Table(name = "push_tokens")
class PushTokenEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(name = "user_id", nullable = false)
	var userId: UUID,
	@Column(name = "fcm_token", nullable = false, columnDefinition = "text")
	var fcmToken: String,
	@Column(nullable = false)
	var platform: String = "ANDROID",
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
	@Column(name = "updated_at", nullable = false)
	var updatedAt: Instant = Instant.now(),
)
