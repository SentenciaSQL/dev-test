package com.apptrial.backend.shared.config

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "apptrial")
data class AppProperties(
	val security: Security = Security(),
	val cors: Cors = Cors(),
	val mail: Mail = Mail(),
	val billing: Billing = Billing(),
	val credits: Credits = Credits(),
) {
	data class Security(
		val jwtSecret: String = "change-me",
		val accessTokenMinutes: Long = 15,
		val refreshTokenDays: Long = 30,
	)

	data class Cors(
		val allowedOrigins: String = "*",
	)

	data class Mail(
		val from: String = "noreply@apptrial.local",
	)

	data class Billing(
		val packageName: String = "com.apptrial.mobile",
		/** MOCK for local/dev; GOOGLE requires Android Publisher client configuration. */
		val verificationMode: String = "MOCK",
	)

	data class Credits(
		val freeInitialGrant: Int = 20,
		val defaultGroupSize: Int = 15,
		val minGroupSize: Int = 12,
	)
}
