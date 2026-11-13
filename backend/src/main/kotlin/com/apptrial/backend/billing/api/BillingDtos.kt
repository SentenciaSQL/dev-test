package com.apptrial.backend.billing.api

import jakarta.validation.constraints.NotBlank
import java.time.Instant

data class ProductResponse(
	val id: String,
	val sku: String,
	val productType: String,
	val title: String,
	val creditsTc: Int?,
	val priceUsdCents: Int?,
)

data class SubscriptionPlanResponse(
	val id: String,
	val code: String,
	val sku: String?,
	val monthlyCreditsTc: Int,
	val maxProjects: Int?,
	val priceUsdCents: Int,
)

data class VerifyPurchaseRequest(
	@field:NotBlank
	val productId: String,
	@field:NotBlank
	val purchaseToken: String,
	@field:NotBlank
	val packageName: String,
)

data class VerifyPurchaseResponse(
	val orderId: String,
	val paymentId: String,
	val status: String,
	val creditedTc: Int?,
	val subscriptionId: String?,
)

data class SubscriptionResponse(
	val id: String,
	val planCode: String,
	val status: String,
	val currentPeriodEnd: Instant?,
)

data class RtdnPayload(
	val message: Map<String, Any?>? = null,
	val subscription: String? = null,
)
