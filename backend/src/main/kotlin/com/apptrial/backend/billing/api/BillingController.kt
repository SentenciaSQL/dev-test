package com.apptrial.backend.billing.api

import com.apptrial.backend.billing.service.BillingService
import com.apptrial.backend.shared.web.SecurityUtils
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/v1/billing")
class BillingController(
	private val billingService: BillingService,
) {
	@GetMapping("/products")
	fun products(): List<ProductResponse> = billingService.listProducts()

	@GetMapping("/plans")
	fun plans(): List<SubscriptionPlanResponse> = billingService.listPlans()

	@GetMapping("/subscriptions")
	fun mySubscriptions(): List<SubscriptionResponse> =
		billingService.mySubscriptions(SecurityUtils.currentUser().id)

	@PostMapping("/purchases/verify")
	fun verify(
		@Valid @RequestBody body: VerifyPurchaseRequest,
		@RequestHeader(name = "Idempotency-Key", required = false) idempotencyKey: String?,
	): VerifyPurchaseResponse =
		billingService.verifyPurchase(SecurityUtils.currentUser(), body, idempotencyKey)

	@PostMapping("/rtdn")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	fun rtdn(@RequestBody(required = false) body: RtdnPayload?) {
		val data = body?.message?.get("data") as? String
		billingService.handleRtdn(data)
	}
}
