package com.apptrial.backend.credits.api

import com.apptrial.backend.credits.domain.CreditTransactionRepository
import com.apptrial.backend.credits.service.CreditWalletService
import com.apptrial.backend.shared.web.SecurityUtils
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.time.Instant

data class WalletResponse(
	val availableBalance: Int,
	val reservedBalance: Int,
)

data class CreditTransactionResponse(
	val id: String,
	val entryType: String,
	val amountTc: Int,
	val creditOrigin: String?,
	val balanceAfter: Int,
	val reservedAfter: Int,
	val referenceType: String?,
	val referenceId: String?,
	val createdAt: Instant,
)

@RestController
@RequestMapping("/api/v1/wallet")
class WalletController(
	private val creditWalletService: CreditWalletService,
	private val transactionRepository: CreditTransactionRepository,
) {
	@GetMapping
	fun wallet(): WalletResponse {
		val wallet = creditWalletService.getWallet(SecurityUtils.currentUser().id)
		return WalletResponse(
			availableBalance = wallet.availableBalance,
			reservedBalance = wallet.reservedBalance,
		)
	}

	@GetMapping("/transactions")
	fun transactions(): List<CreditTransactionResponse> {
		val wallet = creditWalletService.getWallet(SecurityUtils.currentUser().id)
		return transactionRepository.findAllByWalletIdOrderByCreatedAtDesc(wallet.id).map {
			CreditTransactionResponse(
				id = it.id.toString(),
				entryType = it.entryType,
				amountTc = it.amountTc,
				creditOrigin = it.creditOrigin,
				balanceAfter = it.balanceAfter,
				reservedAfter = it.reservedAfter,
				referenceType = it.referenceType,
				referenceId = it.referenceId?.toString(),
				createdAt = it.createdAt,
			)
		}
	}
}
