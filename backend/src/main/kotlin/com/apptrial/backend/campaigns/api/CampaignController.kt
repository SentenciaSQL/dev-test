package com.apptrial.backend.campaigns.api

import com.apptrial.backend.campaigns.service.CampaignService
import com.apptrial.backend.shared.web.SecurityUtils
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

@RestController
@RequestMapping("/api/v1/campaigns")
class CampaignController(
	private val campaignService: CampaignService,
) {
	@GetMapping
	fun listMine(): List<CampaignResponse> =
		campaignService.listMine(SecurityUtils.currentUser().id)

	@GetMapping("/explore")
	fun explore(
		@RequestParam(required = false) country: String?,
		@RequestParam(required = false) sdkInt: Int?,
	): List<CampaignResponse> = campaignService.explore(country, sdkInt)

	@GetMapping("/{id}")
	fun get(@PathVariable id: UUID): CampaignResponse =
		campaignService.get(id, SecurityUtils.currentUser())

	@PostMapping
	@ResponseStatus(HttpStatus.CREATED)
	fun create(@Valid @RequestBody body: CreateCampaignRequest): CampaignResponse =
		campaignService.create(SecurityUtils.currentUser(), body)

	@PatchMapping("/{id}")
	fun update(
		@PathVariable id: UUID,
		@Valid @RequestBody body: UpdateCampaignRequest,
	): CampaignResponse = campaignService.update(SecurityUtils.currentUser(), id, body)

	@PostMapping("/{id}/publish")
	fun publish(@PathVariable id: UUID): CampaignResponse =
		campaignService.publish(SecurityUtils.currentUser(), id)

	@PostMapping("/{id}/cancel")
	fun cancel(@PathVariable id: UUID): CampaignResponse =
		campaignService.cancel(SecurityUtils.currentUser(), id)
}
