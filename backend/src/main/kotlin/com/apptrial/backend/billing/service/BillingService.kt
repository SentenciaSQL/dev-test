package com.apptrial.backend.billing.service

import com.apptrial.backend.billing.api.ProductResponse
import com.apptrial.backend.billing.api.SubscriptionPlanResponse
import com.apptrial.backend.billing.api.SubscriptionResponse
import com.apptrial.backend.billing.api.VerifyPurchaseRequest
import com.apptrial.backend.billing.api.VerifyPurchaseResponse
import com.apptrial.backend.billing.domain.OrderEntity
import com.apptrial.backend.billing.domain.OrderRepository
import com.apptrial.backend.billing.domain.PaymentEntity
import com.apptrial.backend.billing.domain.PaymentRepository
import com.apptrial.backend.billing.domain.ProductRepository
import com.apptrial.backend.billing.domain.SubscriptionEntity
import com.apptrial.backend.billing.domain.SubscriptionPlanRepository
import com.apptrial.backend.billing.domain.SubscriptionRepository
import com.apptrial.backend.credits.service.CreditWalletService
import com.apptrial.backend.shared.error.ConflictException
import com.apptrial.backend.shared.error.NotFoundException
import com.apptrial.backend.shared.error.ValidationApiException
import com.apptrial.backend.shared.security.UserPrincipal
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.time.temporal.ChronoUnit
import java.util.UUID

@Service
class BillingService(
	private val productRepository: ProductRepository,
	private val orderRepository: OrderRepository,
	private val paymentRepository: PaymentRepository,
	private val planRepository: SubscriptionPlanRepository,
	private val subscriptionRepository: SubscriptionRepository,
	private val playBillingVerifier: PlayBillingVerifier,
	private val creditWalletService: CreditWalletService,
) {
	private val log = LoggerFactory.getLogger(javaClass)

	@Transactional(readOnly = true)
	fun listProducts(): List<ProductResponse> =
		productRepository.findAllByActiveTrueOrderByPriceUsdCentsAsc().map {
			ProductResponse(
				id = it.id.toString(),
				sku = it.sku,
				productType = it.productType,
				title = it.title,
				creditsTc = it.creditsTc,
				priceUsdCents = it.priceUsdCents,
			)
		}

	@Transactional(readOnly = true)
	fun listPlans(): List<SubscriptionPlanResponse> =
		planRepository.findAllByActiveTrueOrderByPriceUsdCentsAsc().map {
			SubscriptionPlanResponse(
				id = it.id.toString(),
				code = it.code,
				sku = it.sku,
				monthlyCreditsTc = it.monthlyCreditsTc,
				maxProjects = it.maxProjects,
				priceUsdCents = it.priceUsdCents,
			)
		}

	@Transactional(readOnly = true)
	fun mySubscriptions(userId: UUID): List<SubscriptionResponse> {
		val plans = planRepository.findAll().associateBy { it.id }
		return subscriptionRepository.findAllByUserIdOrderByCreatedAtDesc(userId).map {
			SubscriptionResponse(
				id = it.id.toString(),
				planCode = plans[it.planId]?.code ?: "UNKNOWN",
				status = it.status,
				currentPeriodEnd = it.currentPeriodEnd,
			)
		}
	}

	@Transactional
	fun verifyPurchase(
		principal: UserPrincipal,
		request: VerifyPurchaseRequest,
		idempotencyKey: String?,
	): VerifyPurchaseResponse {
		val existingPayment = paymentRepository.findByPurchaseToken(request.purchaseToken)
		if (existingPayment != null) {
			val order = orderRepository.findById(existingPayment.orderId).orElseThrow()
			val product = productRepository.findById(order.productId).orElseThrow()
			return VerifyPurchaseResponse(
				orderId = order.id.toString(),
				paymentId = existingPayment.id.toString(),
				status = existingPayment.status,
				creditedTc = product.creditsTc,
				subscriptionId = subscriptionRepository.findByPurchaseToken(request.purchaseToken)?.id?.toString(),
			)
		}

		val product = productRepository.findBySku(request.productId)
			?: throw NotFoundException("Unknown product SKU")
		if (!product.active) throw ConflictException("Product is inactive")

		val verification = if (product.productType == "SUBSCRIPTION") {
			playBillingVerifier.verifySubscription(request.packageName, product.sku, request.purchaseToken)
		} else {
			playBillingVerifier.verifyProduct(request.packageName, product.sku, request.purchaseToken)
		}
		if (!verification.valid) throw ValidationApiException("Purchase verification failed")

		val now = Instant.now()
		val order = orderRepository.save(
			OrderEntity(userId = principal.id, productId = product.id, status = "PAID", updatedAt = now),
		)
		val payment = paymentRepository.save(
			PaymentEntity(
				orderId = order.id,
				userId = principal.id,
				purchaseToken = request.purchaseToken,
				playOrderId = verification.playOrderId,
				packageName = request.packageName,
				rawVerification = verification.raw,
				status = "VERIFIED",
				acknowledgedAt = now,
				consumedAt = if (product.productType == "CONSUMABLE_CREDITS") now else null,
			),
		)

		var credited: Int? = null
		var subscriptionId: String? = null

		when (product.productType) {
			"CONSUMABLE_CREDITS" -> {
				val credits = product.creditsTc
					?: throw ValidationApiException("Product has no credits configured")
				val wallet = creditWalletService.getWallet(principal.id)
				creditWalletService.applyEntry(
					wallet = wallet,
					entryType = "PURCHASE",
					amountTc = credits,
					creditOrigin = "PURCHASED",
					idempotencyKey = idempotencyKey ?: "purchase:${request.purchaseToken}",
					referenceType = "PAYMENT",
					referenceId = payment.id,
					metadata = mapOf("sku" to product.sku),
				)
				payment.status = "CONSUMED"
				paymentRepository.save(payment)
				credited = credits
			}
			"SUBSCRIPTION" -> {
				val plan = planRepository.findBySku(product.sku)
					?: throw NotFoundException("Subscription plan not found for SKU")
				val sub = subscriptionRepository.save(
					SubscriptionEntity(
						userId = principal.id,
						planId = plan.id,
						purchaseToken = request.purchaseToken,
						status = "ACTIVE",
						currentPeriodEnd = now.plus(30, ChronoUnit.DAYS),
					),
				)
				if (plan.monthlyCreditsTc > 0) {
					val wallet = creditWalletService.getWallet(principal.id)
					creditWalletService.applyEntry(
						wallet = wallet,
						entryType = "SUBSCRIPTION_GRANT",
						amountTc = plan.monthlyCreditsTc,
						creditOrigin = "SUBSCRIPTION",
						idempotencyKey = idempotencyKey ?: "sub-grant:${request.purchaseToken}:$now",
						referenceType = "SUBSCRIPTION",
						referenceId = sub.id,
						metadata = mapOf("plan" to plan.code),
					)
					credited = plan.monthlyCreditsTc
				}
				subscriptionId = sub.id.toString()
			}
			else -> throw ValidationApiException("Unsupported product type")
		}

		return VerifyPurchaseResponse(
			orderId = order.id.toString(),
			paymentId = payment.id.toString(),
			status = payment.status,
			creditedTc = credited,
			subscriptionId = subscriptionId,
		)
	}

	@Transactional
	fun handleRtdn(encodedData: String?) {
		// RTDN arrives via Pub/Sub. Decode and act on refunds/cancellations using
		// official Real-time developer notifications payload fields — no invented APIs.
		log.info("RTDN received (ack only in MVP). dataPresent={}", !encodedData.isNullOrBlank())
	}
}
