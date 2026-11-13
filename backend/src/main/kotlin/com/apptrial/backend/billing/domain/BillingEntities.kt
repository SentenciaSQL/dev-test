package com.apptrial.backend.billing.domain

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table
import org.hibernate.annotations.JdbcTypeCode
import org.hibernate.type.SqlTypes
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "products")
class ProductEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(nullable = false, unique = true)
	var sku: String,
	@Column(name = "product_type", nullable = false)
	var productType: String,
	@Column(nullable = false)
	var title: String,
	@Column(name = "credits_tc")
	var creditsTc: Int? = null,
	@Column(name = "price_usd_cents")
	var priceUsdCents: Int? = null,
	@Column(nullable = false)
	var active: Boolean = true,
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
)

@Entity
@Table(name = "orders")
class OrderEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(name = "user_id", nullable = false)
	var userId: UUID,
	@Column(name = "product_id", nullable = false)
	var productId: UUID,
	@Column(nullable = false)
	var status: String = "PENDING",
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
	@Column(name = "updated_at", nullable = false)
	var updatedAt: Instant = Instant.now(),
)

@Entity
@Table(name = "payments")
class PaymentEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(name = "order_id", nullable = false)
	var orderId: UUID,
	@Column(name = "user_id", nullable = false)
	var userId: UUID,
	@Column(name = "purchase_token", nullable = false, unique = true, columnDefinition = "text")
	var purchaseToken: String,
	@Column(name = "play_order_id", columnDefinition = "text")
	var playOrderId: String? = null,
	@Column(name = "package_name", nullable = false)
	var packageName: String,
	@JdbcTypeCode(SqlTypes.JSON)
	@Column(name = "raw_verification", columnDefinition = "jsonb")
	var rawVerification: Map<String, Any?>? = null,
	@Column(nullable = false)
	var status: String = "VERIFIED",
	@Column(name = "acknowledged_at")
	var acknowledgedAt: Instant? = null,
	@Column(name = "consumed_at")
	var consumedAt: Instant? = null,
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
)

@Entity
@Table(name = "subscription_plans")
class SubscriptionPlanEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(nullable = false, unique = true)
	var code: String,
	var sku: String? = null,
	@Column(name = "monthly_credits_tc", nullable = false)
	var monthlyCreditsTc: Int = 0,
	@Column(name = "max_projects")
	var maxProjects: Int? = null,
	@Column(name = "price_usd_cents", nullable = false)
	var priceUsdCents: Int = 0,
	@Column(nullable = false)
	var active: Boolean = true,
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
)

@Entity
@Table(name = "subscriptions")
class SubscriptionEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(name = "user_id", nullable = false)
	var userId: UUID,
	@Column(name = "plan_id", nullable = false)
	var planId: UUID,
	@Column(name = "purchase_token", columnDefinition = "text")
	var purchaseToken: String? = null,
	@Column(nullable = false)
	var status: String = "ACTIVE",
	@Column(name = "current_period_end")
	var currentPeriodEnd: Instant? = null,
	@Column(name = "cancelled_at")
	var cancelledAt: Instant? = null,
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
	@Column(name = "updated_at", nullable = false)
	var updatedAt: Instant = Instant.now(),
)
