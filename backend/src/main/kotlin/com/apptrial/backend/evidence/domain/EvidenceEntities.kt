package com.apptrial.backend.evidence.domain

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "evidence_files")
class EvidenceFileEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(name = "submission_id", nullable = false)
	var submissionId: UUID,
	@Column(name = "storage_key", nullable = false, columnDefinition = "text")
	var storageKey: String,
	@Column(name = "content_type", nullable = false)
	var contentType: String,
	@Column(name = "size_bytes", nullable = false)
	var sizeBytes: Long,
	@Column(name = "checksum_sha256")
	var checksumSha256: String? = null,
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
)
