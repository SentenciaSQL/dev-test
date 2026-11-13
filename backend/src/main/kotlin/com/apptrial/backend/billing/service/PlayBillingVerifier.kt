package com.apptrial.backend.billing.service

import com.apptrial.backend.shared.config.AppProperties
import com.apptrial.backend.shared.error.ValidationApiException
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component

data class PlayVerificationResult(
	val valid: Boolean,
	val playOrderId: String?,
	val productId: String,
	val purchaseState: String,
	val raw: Map<String, Any?>,
)

/**
 * Verifies Google Play purchase tokens.
 *
 * Modes:
 * - MOCK: accepts well-formed tokens for local/dev (never use in production)
 * - GOOGLE: reserved for Android Publisher API integration when service-account
 *   credentials are configured. Does not invent Google APIs; fails closed until wired.
 *
 * Official docs: Google Play Developer API — purchases.products / purchases.subscriptionsv2
 */
@Component
class PlayBillingVerifier(
	private val props: AppProperties,
) {
	private val log = LoggerFactory.getLogger(javaClass)

	fun verifyProduct(packageName: String, productId: String, purchaseToken: String): PlayVerificationResult {
		requirePackage(packageName)
		require(purchaseToken.isNotBlank()) { "purchaseToken required" }
		return when (props.billing.verificationMode.uppercase()) {
			"MOCK" -> mockVerify(productId, purchaseToken, subscription = false)
			"GOOGLE" -> googleVerify(packageName, productId, purchaseToken, subscription = false)
			else -> throw ValidationApiException("Unsupported billing verification mode")
		}
	}

	fun verifySubscription(packageName: String, productId: String, purchaseToken: String): PlayVerificationResult {
		requirePackage(packageName)
		return when (props.billing.verificationMode.uppercase()) {
			"MOCK" -> mockVerify(productId, purchaseToken, subscription = true)
			"GOOGLE" -> googleVerify(packageName, productId, purchaseToken, subscription = true)
			else -> throw ValidationApiException("Unsupported billing verification mode")
		}
	}

	private fun mockVerify(productId: String, purchaseToken: String, subscription: Boolean): PlayVerificationResult {
		log.warn("Using MOCK Play Billing verification — not for production")
		if (purchaseToken.length < 8) {
			throw ValidationApiException("Invalid purchase token")
		}
		return PlayVerificationResult(
			valid = true,
			playOrderId = "GPA.MOCK-${purchaseToken.takeLast(8)}",
			productId = productId,
			purchaseState = "PURCHASED",
			raw = mapOf(
				"mode" to "MOCK",
				"subscription" to subscription,
				"purchaseToken" to purchaseToken,
			),
		)
	}

	private fun googleVerify(
		packageName: String,
		productId: String,
		purchaseToken: String,
		subscription: Boolean,
	): PlayVerificationResult {
		// Intentionally not fabricating a Google client. Wire google-api-services-androidpublisher
		// with a service account and call purchases.products.get / purchases.subscriptionsv2.get.
		log.error(
			"GOOGLE verification mode enabled but Android Publisher client is not configured. " +
				"package={} product={} subscription={}",
			packageName,
			productId,
			subscription,
		)
		throw ValidationApiException(
			"Google Play Developer API client is not configured",
			listOf(
				"Set apptrial.billing.verification-mode=MOCK for local development",
				"Configure a Play service account and implement Android Publisher calls for production",
			),
		)
	}

	private fun requirePackage(packageName: String) {
		if (packageName != props.billing.packageName) {
			throw ValidationApiException(
				"packageName mismatch",
				listOf("Expected ${props.billing.packageName}"),
			)
		}
	}
}
