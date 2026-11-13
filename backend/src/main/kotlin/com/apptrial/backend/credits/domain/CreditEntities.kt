package com.apptrial.backend.credits.domain

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table
import jakarta.persistence.Version
import org.hibernate.annotations.JdbcTypeCode
import org.hibernate.type.SqlTypes
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "credit_wallets")
class CreditWalletEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(name = "user_id", nullable = false, unique = true)
	var userId: UUID,
	@Column(name = "available_balance", nullable = false)
	var availableBalance: Int = 0,
	@Column(name = "reserved_balance", nullable = false)
	var reservedBalance: Int = 0,
	@Version
	var version: Long = 0,
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
	@Column(name = "updated_at", nullable = false)
	var updatedAt: Instant = Instant.now(),
)

@Entity
@Table(name = "credit_transactions")
class CreditTransactionEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(name = "wallet_id", nullable = false)
	var walletId: UUID,
	@Column(name = "entry_type", nullable = false)
	var entryType: String,
	@Column(name = "amount_tc", nullable = false)
	var amountTc: Int,
	@Column(name = "credit_origin")
	var creditOrigin: String? = null,
	@Column(name = "balance_after", nullable = false)
	var balanceAfter: Int,
	@Column(name = "reserved_after", nullable = false)
	var reservedAfter: Int,
	@Column(name = "reference_type")
	var referenceType: String? = null,
	@Column(name = "reference_id")
	var referenceId: UUID? = null,
	@Column(name = "idempotency_key", unique = true)
	var idempotencyKey: String? = null,
	@JdbcTypeCode(SqlTypes.JSON)
	@Column(nullable = false, columnDefinition = "jsonb")
	var metadata: Map<String, Any?> = emptyMap(),
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
)
