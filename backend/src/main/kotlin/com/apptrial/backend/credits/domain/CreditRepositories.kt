package com.apptrial.backend.credits.domain

import org.springframework.data.jpa.repository.JpaRepository
import java.util.UUID

interface CreditWalletRepository : JpaRepository<CreditWalletEntity, UUID> {
	fun findByUserId(userId: UUID): CreditWalletEntity?
}

interface CreditTransactionRepository : JpaRepository<CreditTransactionEntity, UUID> {
	fun findByIdempotencyKey(idempotencyKey: String): CreditTransactionEntity?
}
