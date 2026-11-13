package com.apptrial.backend.notifications.api

import com.apptrial.backend.notifications.service.NotificationService
import com.apptrial.backend.notifications.service.NotificationView
import com.apptrial.backend.shared.web.SecurityUtils
import com.apptrial.backend.users.domain.UserRepository
import com.apptrial.backend.shared.error.NotFoundException
import jakarta.validation.constraints.NotBlank
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController
import java.time.Instant
import java.util.UUID

data class PushTokenRequest(
	@field:NotBlank val fcmToken: String,
	val platform: String = "ANDROID",
)

data class NotificationPrefsRequest(
	val preferences: Map<String, Boolean>,
)

data class UnreadCountResponse(val unread: Long)

@RestController
@RequestMapping("/api/v1")
class NotificationController(
	private val notificationService: NotificationService,
	private val userRepository: UserRepository,
) {
	@GetMapping("/notifications")
	fun list(): List<NotificationView> =
		notificationService.list(SecurityUtils.currentUser().id)

	@GetMapping("/notifications/unread-count")
	fun unread(): UnreadCountResponse =
		UnreadCountResponse(notificationService.unreadCount(SecurityUtils.currentUser().id))

	@PostMapping("/notifications/{id}/read")
	fun markRead(@PathVariable id: UUID): NotificationView =
		notificationService.markRead(SecurityUtils.currentUser().id, id)

	@PostMapping("/notifications/read-all")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	fun markAllRead() {
		notificationService.markAllRead(SecurityUtils.currentUser().id)
	}

	@PostMapping("/push-tokens")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	fun registerToken(@RequestBody body: PushTokenRequest) {
		notificationService.registerPushToken(
			SecurityUtils.currentUser().id,
			body.fcmToken,
			body.platform,
		)
	}

	@DeleteMapping("/push-tokens")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	fun unregisterToken(@RequestBody body: PushTokenRequest) {
		notificationService.unregisterPushToken(SecurityUtils.currentUser().id, body.fcmToken)
	}

	@GetMapping("/me/notification-preferences")
	fun getPrefs(): Map<String, Any?> {
		val user = userRepository.findById(SecurityUtils.currentUser().id)
			.orElseThrow { NotFoundException("User not found") }
		return user.notificationPrefs
	}

	@PutMapping("/me/notification-preferences")
	fun putPrefs(@RequestBody body: NotificationPrefsRequest): Map<String, Any?> {
		val user = userRepository.findById(SecurityUtils.currentUser().id)
			.orElseThrow { NotFoundException("User not found") }
		user.notificationPrefs = body.preferences
		user.updatedAt = Instant.now()
		userRepository.save(user)
		return user.notificationPrefs
	}
}
