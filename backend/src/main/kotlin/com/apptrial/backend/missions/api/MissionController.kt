package com.apptrial.backend.missions.api

import com.apptrial.backend.missions.service.MissionService
import com.apptrial.backend.shared.storage.EvidenceStorage
import com.apptrial.backend.shared.web.SecurityUtils
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

@RestController
@RequestMapping("/api/v1")
class MissionController(
	private val missionService: MissionService,
	private val evidenceStorage: EvidenceStorage,
) {
	@GetMapping("/campaigns/{campaignId}/missions")
	fun listMissions(@PathVariable campaignId: UUID): List<MissionResponse> =
		missionService.listMissions(campaignId, SecurityUtils.currentUser())

	@PostMapping("/campaigns/{campaignId}/missions")
	@ResponseStatus(HttpStatus.CREATED)
	fun createMission(
		@PathVariable campaignId: UUID,
		@Valid @RequestBody body: CreateMissionRequest,
	): MissionResponse = missionService.createMission(campaignId, SecurityUtils.currentUser(), body)

	@PutMapping("/campaigns/{campaignId}/missions/{missionId}")
	fun updateMission(
		@PathVariable campaignId: UUID,
		@PathVariable missionId: UUID,
		@Valid @RequestBody body: UpdateMissionRequest,
	): MissionResponse = missionService.updateMission(campaignId, missionId, SecurityUtils.currentUser(), body)

	@PostMapping("/missions/{missionId}/submissions")
	@ResponseStatus(HttpStatus.CREATED)
	fun submit(
		@PathVariable missionId: UUID,
		@Valid @RequestBody body: SubmitMissionRequest,
	): SubmissionResponse = missionService.submit(missionId, SecurityUtils.currentUser(), body)

	@GetMapping("/missions/{missionId}/submissions")
	fun listSubmissions(@PathVariable missionId: UUID): List<SubmissionResponse> =
		missionService.listSubmissionsForMission(missionId, SecurityUtils.currentUser())

	@GetMapping("/me/submissions")
	fun mySubmissions(): List<SubmissionResponse> =
		missionService.listMySubmissions(SecurityUtils.currentUser().id)

	@PostMapping("/submissions/{submissionId}/review")
	fun review(
		@PathVariable submissionId: UUID,
		@Valid @RequestBody body: ReviewSubmissionRequest,
	): SubmissionResponse = missionService.review(submissionId, SecurityUtils.currentUser(), body)

	@PostMapping("/submissions/{submissionId}/evidence-uploads")
	@ResponseStatus(HttpStatus.CREATED)
	fun evidenceUpload(
		@PathVariable submissionId: UUID,
		@Valid @RequestBody body: EvidenceUploadRequest,
	): EvidenceUploadResponse =
		missionService.requestEvidenceUpload(submissionId, SecurityUtils.currentUser(), body)

	@GetMapping("/submissions/{submissionId}/evidence")
	fun listEvidence(@PathVariable submissionId: UUID): List<EvidenceFileResponse> =
		missionService.listEvidence(submissionId, SecurityUtils.currentUser())

	/**
	 * Local upload target used by EvidenceStorage upload URLs.
	 * In production this is replaced by a direct S3 PUT to a signed URL.
	 */
	@PutMapping("/evidence-uploads/{encodedKey}")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	fun putEvidenceLocal(
		@PathVariable encodedKey: String,
		@RequestBody bytes: ByteArray,
	) {
		val storageKey = encodedKey.replace("__", "/")
		evidenceStorage.store(storageKey, bytes)
	}
}
