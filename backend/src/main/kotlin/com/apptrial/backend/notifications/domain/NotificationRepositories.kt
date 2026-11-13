package com.apptrial.backend.notifications.domain

import org.springframework.data.jpa.repository.JpaRepository
import java.util.UUID

interface NotificationRepository : JpaRepository<NotificationEntity, UUID> {
	fun findAllByUserIdOrderByCreatedAtDesc(userId: UUID): List<NotificationEntity>
	fun findByIdAndUserId(id: UUID, userId: UUID): NotificationEntity?
	fun countByUserIdAndReadAtIsNull(userId: UUID): Long
}

interface PushTokenRepository : JpaRepository<PushTokenEntity, UUID> {
	fun findAllByUserId(userId: UUID): List<PushTokenEntity>
	fun findByUserIdAndFcmToken(userId: UUID, fcmToken: String): PushTokenEntity?
	fun deleteByUserIdAndFcmToken(userId: UUID, fcmToken: String)
}
