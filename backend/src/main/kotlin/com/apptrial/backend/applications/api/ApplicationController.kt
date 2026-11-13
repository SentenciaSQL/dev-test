package com.apptrial.backend.applications.api

import com.apptrial.backend.applications.service.ApplicationService
import com.apptrial.backend.shared.web.SecurityUtils
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
@RequestMapping("/api/v1/applications")
class ApplicationController(
	private val applicationService: ApplicationService,
) {
	@GetMapping
	fun listMine(): List<ApplicationResponse> =
		applicationService.listMine(SecurityUtils.currentUser().id)

	@GetMapping("/{id}")
	fun get(@PathVariable id: UUID): ApplicationResponse =
		applicationService.getOwned(id, SecurityUtils.currentUser().id)

	@PostMapping
	@ResponseStatus(HttpStatus.CREATED)
	fun create(@Valid @RequestBody body: CreateApplicationRequest): ApplicationResponse =
		applicationService.create(SecurityUtils.currentUser(), body)

	@PatchMapping("/{id}")
	fun update(
		@PathVariable id: UUID,
		@Valid @RequestBody body: UpdateApplicationRequest,
	): ApplicationResponse = applicationService.update(SecurityUtils.currentUser(), id, body)

	@DeleteMapping("/{id}")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	fun archive(@PathVariable id: UUID) {
		applicationService.archive(SecurityUtils.currentUser(), id)
	}
}
