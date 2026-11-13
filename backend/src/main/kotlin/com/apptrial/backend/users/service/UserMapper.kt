package com.apptrial.backend.users.service

import com.apptrial.backend.users.api.DeviceResponse
import com.apptrial.backend.users.api.UserResponse
import com.apptrial.backend.users.domain.UserDeviceEntity
import com.apptrial.backend.users.domain.UserEntity

object UserMapper {
	fun toResponse(user: UserEntity) = UserResponse(
		id = user.id.toString(),
		email = user.email,
		displayName = user.displayName,
		photoUrl = user.photoUrl,
		countryCode = user.countryCode,
		locale = user.locale,
		emailVerified = user.emailVerifiedAt != null,
		roles = user.roles.toSet(),
		reputationScore = user.reputationScore,
		notificationPreferences = user.notificationPrefs,
		createdAt = user.createdAt,
	)

	fun toDeviceResponse(device: UserDeviceEntity) = DeviceResponse(
		id = device.id.toString(),
		deviceFingerprint = device.deviceFingerprint,
		model = device.model,
		manufacturer = device.manufacturer,
		androidVersion = device.androidVersion,
		sdkInt = device.sdkInt,
		primary = device.primary,
		lastSeenAt = device.lastSeenAt,
		createdAt = device.createdAt,
	)
}
