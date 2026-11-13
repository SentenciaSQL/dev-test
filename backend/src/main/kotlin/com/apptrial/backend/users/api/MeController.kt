package com.apptrial.backend.users.api

import com.apptrial.backend.shared.web.SecurityUtils
import com.apptrial.backend.users.service.UserService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

@RestController
@RequestMapping("/api/v1/me")
class MeController(
	private val userService: UserService,
) {
	@GetMapping
	fun me(): UserResponse = userService.getMe(SecurityUtils.currentUser().id)

	@PatchMapping
	fun update(@Valid @RequestBody body: UpdateProfileRequest): UserResponse =
		userService.updateMe(SecurityUtils.currentUser().id, body)

	@GetMapping("/devices")
	fun devices(): List<DeviceResponse> = userService.listDevices(SecurityUtils.currentUser().id)

	@PostMapping("/devices")
	@ResponseStatus(HttpStatus.CREATED)
	fun addDevice(@Valid @RequestBody body: DeviceRequest): DeviceResponse =
		userService.addDevice(SecurityUtils.currentUser().id, body)

	@DeleteMapping("/devices/{deviceId}")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	fun deleteDevice(@PathVariable deviceId: UUID) {
		userService.deleteDevice(SecurityUtils.currentUser().id, deviceId)
	}
}
