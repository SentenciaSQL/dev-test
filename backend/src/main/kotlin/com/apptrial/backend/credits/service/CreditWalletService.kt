package com.apptrial.backend.credits.service

import com.apptrial.backend.credits.domain.CreditTransactionEntity
import com.apptrial.backend.credits.domain.CreditTransactionRepository
import com.apptrial.backend.credits.domain.CreditWalletEntity
import com.apptrial.backend.credits.domain.CreditWalletRepository
import com.apptrial.backend.shared.config.AppProperties
import com.apptrial.backend.shared.error.ConflictException
import com.apptrial.backend.shared.error.NotFoundException
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

@Service
class CreditWalletService(
	private val walletRepository: CreditWalletRepository,
	private val transactionRepository: CreditTransactionRepository,
	private val props: AppProperties,
) {
	@Transactional
	fun createWalletWithWelcomeGrant(userId: UUID): CreditWalletEntity {
		walletRepository.findByUserId(userId)?.let { return it }
		val wallet = walletRepository.save(CreditWalletEntity(userId = userId))
		val grant = props.credits.freeInitialGrant
		if (grant > 0) {
			applyEntry(
				wallet = wallet,
				entryType = "PROMOTIONAL",
				amountTc = grant,
				creditOrigin = "PROMOTIONAL",
				idempotencyKey = "welcome-grant:$userId",
				referenceType = "WELCOME",
				metadata = mapOf("reason" to "free_plan_initial_grant"),
			)
		}
		return wallet
	}

	@Transactional(readOnly = true)
	fun getWallet(userId: UUID): CreditWalletEntity =
		walletRepository.findByUserId(userId) ?: throw NotFoundException("Wallet not found")

	@Transactional
	fun applyEntry(
		wallet: CreditWalletEntity,
		entryType: String,
		amountTc: Int,
		creditOrigin: String? = null,
		idempotencyKey: String? = null,
		referenceType: String? = null,
		referenceId: UUID? = null,
		metadata: Map<String, Any?> = emptyMap(),
	): CreditTransactionEntity {
		if (idempotencyKey != null) {
			transactionRepository.findByIdempotencyKey(idempotencyKey)?.let { return it }
		}

		when (entryType) {
			"RESERVE" -> {
				if (wallet.availableBalance < amountTc) {
					throw ConflictException("Insufficient available credits")
				}
				wallet.availableBalance -= amountTc
				wallet.reservedBalance += amountTc
			}
			"RELEASE" -> {
				if (wallet.reservedBalance < amountTc) {
					throw ConflictException("Insufficient reserved credits")
				}
				wallet.reservedBalance -= amountTc
				wallet.availableBalance += amountTc
			}
			"SPEND" -> {
				if (wallet.reservedBalance < amountTc) {
					throw ConflictException("Insufficient reserved credits to spend")
				}
				wallet.reservedBalance -= amountTc
			}
			else -> {
				wallet.availableBalance += amountTc
				if (wallet.availableBalance < 0) {
					throw ConflictException("Credit balance cannot be negative")
				}
			}
		}
		wallet.updatedAt = Instant.now()
		walletRepository.save(wallet)

		return transactionRepository.save(
			CreditTransactionEntity(
				walletId = wallet.id,
				entryType = entryType,
				amountTc = amountTc,
				creditOrigin = creditOrigin,
				balanceAfter = wallet.availableBalance,
				reservedAfter = wallet.reservedBalance,
				referenceType = referenceType,
				referenceId = referenceId,
				idempotencyKey = idempotencyKey,
				metadata = metadata,
			),
		)
	}
}
