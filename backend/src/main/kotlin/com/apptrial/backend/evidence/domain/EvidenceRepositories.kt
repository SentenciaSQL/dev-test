package com.apptrial.backend.evidence.domain

import org.springframework.data.jpa.repository.JpaRepository
import java.util.UUID

interface EvidenceFileRepository : JpaRepository<EvidenceFileEntity, UUID> {
	fun findAllBySubmissionIdOrderByCreatedAtAsc(submissionId: UUID): List<EvidenceFileEntity>
	fun findByIdAndSubmissionId(id: UUID, submissionId: UUID): EvidenceFileEntity?
	fun countBySubmissionId(submissionId: UUID): Long
}
