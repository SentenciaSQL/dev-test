package com.apptrial.backend.billing.domain

import org.springframework.data.jpa.repository.JpaRepository
import java.util.UUID

interface ProductRepository : JpaRepository<ProductEntity, UUID> {
	fun findAllByActiveTrueOrderByPriceUsdCentsAsc(): List<ProductEntity>
	fun findBySku(sku: String): ProductEntity?
}

interface OrderRepository : JpaRepository<OrderEntity, UUID>

interface PaymentRepository : JpaRepository<PaymentEntity, UUID> {
	fun findByPurchaseToken(purchaseToken: String): PaymentEntity?
}

interface SubscriptionPlanRepository : JpaRepository<SubscriptionPlanEntity, UUID> {
	fun findAllByActiveTrueOrderByPriceUsdCentsAsc(): List<SubscriptionPlanEntity>
	fun findBySku(sku: String): SubscriptionPlanEntity?
	fun findByCode(code: String): SubscriptionPlanEntity?
}

interface SubscriptionRepository : JpaRepository<SubscriptionEntity, UUID> {
	fun findAllByUserIdOrderByCreatedAtDesc(userId: UUID): List<SubscriptionEntity>
	fun findFirstByUserIdAndStatusOrderByCreatedAtDesc(userId: UUID, status: String): SubscriptionEntity?
	fun findByPurchaseToken(purchaseToken: String): SubscriptionEntity?
}
