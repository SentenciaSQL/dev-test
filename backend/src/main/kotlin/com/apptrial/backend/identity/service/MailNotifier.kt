package com.apptrial.backend.identity.service

import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component

/**
 * Development notifier. Replace with SMTP/provider integration without changing callers.
 */
@Component
class MailNotifier {
	private val log = LoggerFactory.getLogger(javaClass)

	fun sendEmailVerification(email: String, rawToken: String) {
		log.info("EMAIL_VERIFICATION to={} token={}", email, rawToken)
	}

	fun sendPasswordReset(email: String, rawToken: String) {
		log.info("PASSWORD_RESET to={} token={}", email, rawToken)
	}
}
