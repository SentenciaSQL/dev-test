package com.apptrial.backend.notifications.service

import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Component

/**
 * FCM delivery gateway.
 * MOCK logs payloads (local/dev). FIREBASE mode expects a configured Firebase Admin SDK
 * (not invented here — wire official Firebase Admin when credentials exist).
 */
@Component
class FcmPushGateway(
	@Value("\${apptrial.notifications.fcm-mode:MOCK}") private val mode: String,
) {
	private val log = LoggerFactory.getLogger(javaClass)

	fun send(tokens: Collection<String>, title: String, body: String, data: Map<String, String>) {
		if (tokens.isEmpty()) return
		when (mode.uppercase()) {
			"MOCK" -> log.info(
				"FCM_MOCK title={} body={} tokens={} data={}",
				title,
				body,
				tokens.size,
				data,
			)
			"FIREBASE" -> log.warn(
				"FIREBASE FCM mode enabled but Admin SDK is not wired; dropping {} tokens",
				tokens.size,
			)
			else -> log.warn("Unknown FCM mode {}", mode)
		}
	}
}
