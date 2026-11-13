package com.apptrial.backend.identity.service

import java.security.MessageDigest
import java.security.SecureRandom
import java.util.Base64

object TokenHashing {
	private val secureRandom = SecureRandom()

	fun generateRawToken(): String {
		val bytes = ByteArray(32)
		secureRandom.nextBytes(bytes)
		return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes)
	}

	fun sha256(raw: String): String {
		val digest = MessageDigest.getInstance("SHA-256").digest(raw.toByteArray())
		return digest.joinToString("") { "%02x".format(it) }
	}
}
