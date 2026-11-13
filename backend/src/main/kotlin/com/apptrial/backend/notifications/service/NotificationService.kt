package com.apptrial.backend.notifications.service

import com.apptrial.backend.notifications.domain.NotificationEntity
import com.apptrial.backend.notifications.domain.NotificationRepository
import com.apptrial.backend.notifications.domain.PushTokenEntity
import com.apptrial.backend.notifications.domain.PushTokenRepository
import com.apptrial.backend.shared.error.NotFoundException
import com.apptrial.backend.users.domain.UserRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

data class NotificationView(
	val id: String,
	val eventType: String,
	val title: String,
	val body: String,
	val payload: Map<String, Any?>,
	val readAt: Instant?,
	val createdAt: Instant,
)

@Service
class NotificationService(
	private val notificationRepository: NotificationRepository,
	private val pushTokenRepository: PushTokenRepository,
	private val userRepository: UserRepository,
	private val fcmPushGateway: FcmPushGateway,
) {
	@Transactional(readOnly = true)
	fun list(userId: UUID): List<NotificationView> =
		notificationRepository.findAllByUserIdOrderByCreatedAtDesc(userId).map { toView(it) }

	@Transactional(readOnly = true)
	fun unreadCount(userId: UUID): Long =
		notificationRepository.countByUserIdAndReadAtIsNull(userId)

	@Transactional
	fun markRead(userId: UUID, notificationId: UUID): NotificationView {
		val entity = notificationRepository.findByIdAndUserId(notificationId, userId)
			?: throw NotFoundException("Notification not found")
		entity.readAt = Instant.now()
		return toView(notificationRepository.save(entity))
	}

	@Transactional
	fun markAllRead(userId: UUID) {
		notificationRepository.findAllByUserIdOrderByCreatedAtDesc(userId)
			.filter { it.readAt == null }
			.forEach {
				it.readAt = Instant.now()
				notificationRepository.save(it)
			}
	}

	@Transactional
	fun registerPushToken(userId: UUID, token: String, platform: String = "ANDROID") {
		val existing = pushTokenRepository.findByUserIdAndFcmToken(userId, token)
		if (existing != null) {
			existing.updatedAt = Instant.now()
			existing.platform = platform.uppercase()
			pushTokenRepository.save(existing)
			return
		}
		pushTokenRepository.save(
			PushTokenEntity(userId = userId, fcmToken = token, platform = platform.uppercase()),
		)
	}

	@Transactional
	fun unregisterPushToken(userId: UUID, token: String) {
		pushTokenRepository.deleteByUserIdAndFcmToken(userId, token)
	}

	@Transactional
	fun notify(
		userId: UUID,
		eventType: String,
		title: String,
		body: String,
		payload: Map<String, Any?> = emptyMap(),
	): NotificationView {
		val user = userRepository.findById(userId).orElse(null)
		val prefs = user?.notificationPrefs.orEmpty()
		val enabled = (prefs[eventType] as? Boolean) ?: (prefs["all"] as? Boolean) ?: true
		val entity = notificationRepository.save(
			NotificationEntity(
				userId = userId,
				eventType = eventType,
				title = title,
				body = body,
				payload = payload,
			),
		)
		if (enabled) {
			val tokens = pushTokenRepository.findAllByUserId(userId).map { it.fcmToken }
			fcmPushGateway.send(
				tokens = tokens,
				title = title,
				body = body,
				data = payload.mapValues { it.value?.toString() ?: "" } + mapOf("eventType" to eventType),
			)
		}
		return toView(entity)
	}

	private fun toView(entity: NotificationEntity) = NotificationView(
		id = entity.id.toString(),
		eventType = entity.eventType,
		title = entity.title,
		body = entity.body,
		payload = entity.payload,
		readAt = entity.readAt,
		createdAt = entity.createdAt,
	)
}
