package com.apptrial.backend.users.service

import com.apptrial.backend.shared.error.ConflictException
import com.apptrial.backend.shared.error.NotFoundException
import com.apptrial.backend.users.api.DeviceRequest
import com.apptrial.backend.users.api.DeviceResponse
import com.apptrial.backend.users.api.UpdateProfileRequest
import com.apptrial.backend.users.api.UserResponse
import com.apptrial.backend.users.domain.UserDeviceEntity
import com.apptrial.backend.users.domain.UserDeviceRepository
import com.apptrial.backend.users.domain.UserRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

@Service
class UserService(
	private val userRepository: UserRepository,
	private val deviceRepository: UserDeviceRepository,
) {
	@Transactional(readOnly = true)
	fun getMe(userId: UUID): UserResponse {
		val user = userRepository.findById(userId).orElseThrow { NotFoundException("User not found") }
		return UserMapper.toResponse(user)
	}

	@Transactional
	fun updateMe(userId: UUID, request: UpdateProfileRequest): UserResponse {
		val user = userRepository.findById(userId).orElseThrow { NotFoundException("User not found") }
		request.displayName?.let { user.displayName = it.trim() }
		request.photoUrl?.let { user.photoUrl = it }
		request.countryCode?.let { user.countryCode = it.uppercase() }
		request.locale?.let { user.locale = it }
		request.notificationPreferences?.let { user.notificationPrefs = it }
		user.updatedAt = Instant.now()
		return UserMapper.toResponse(userRepository.save(user))
	}

	@Transactional(readOnly = true)
	fun listDevices(userId: UUID): List<DeviceResponse> =
		deviceRepository.findAllByUserIdOrderByCreatedAtDesc(userId).map(UserMapper::toDeviceResponse)

	@Transactional
	fun addDevice(userId: UUID, request: DeviceRequest): DeviceResponse {
		if (deviceRepository.existsByUserIdAndDeviceFingerprint(userId, request.deviceFingerprint)) {
			throw ConflictException("Device already registered")
		}
		if (request.primary) {
			deviceRepository.findAllByUserIdOrderByCreatedAtDesc(userId).forEach {
				if (it.primary) {
					it.primary = false
					it.updatedAt = Instant.now()
					deviceRepository.save(it)
				}
			}
		}
		val device = deviceRepository.save(
			UserDeviceEntity(
				userId = userId,
				deviceFingerprint = request.deviceFingerprint,
				model = request.model,
				manufacturer = request.manufacturer,
				androidVersion = request.androidVersion,
				sdkInt = request.sdkInt,
				primary = request.primary,
				lastSeenAt = Instant.now(),
			),
		)
		return UserMapper.toDeviceResponse(device)
	}

	@Transactional
	fun deleteDevice(userId: UUID, deviceId: UUID) {
		val device = deviceRepository.findByIdAndUserId(deviceId, userId)
			?: throw NotFoundException("Device not found")
		deviceRepository.delete(device)
	}
}
