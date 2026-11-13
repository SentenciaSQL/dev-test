package com.apptrial.backend.shared.storage

import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Component
import java.nio.file.Files
import java.nio.file.Path
import java.time.Instant
import java.util.UUID
import kotlin.io.path.createDirectories
import kotlin.io.path.exists
import kotlin.io.path.writeBytes

data class PresignedUpload(
	val storageKey: String,
	val uploadUrl: String,
	val expiresAt: Instant,
)

/**
 * Local filesystem storage for evidence in non-AWS environments.
 * Production should swap to S3-signed URLs without changing callers.
 */
@Component
class EvidenceStorage(
	@Value("\${apptrial.storage.local-path:./data/evidence}") private val localPath: String,
	@Value("\${apptrial.storage.public-base-url:http://localhost:8080}") private val publicBaseUrl: String,
) {
	fun createUpload(submissionId: UUID, contentType: String): PresignedUpload {
		val key = "evidence/$submissionId/${UUID.randomUUID()}"
		val expiresAt = Instant.now().plusSeconds(900)
		val uploadUrl = "$publicBaseUrl/api/v1/evidence-uploads/${key.replace("/", "__")}"
		return PresignedUpload(storageKey = key, uploadUrl = uploadUrl, expiresAt = expiresAt)
	}

	fun store(storageKey: String, bytes: ByteArray) {
		val path = resolve(storageKey)
		path.parent.createDirectories()
		path.writeBytes(bytes)
	}

	fun exists(storageKey: String): Boolean = resolve(storageKey).exists()

	fun resolve(storageKey: String): Path = Path.of(localPath).resolve(storageKey)

	fun ensureRoot() {
		Files.createDirectories(Path.of(localPath))
	}
}
