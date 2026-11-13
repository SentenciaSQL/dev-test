package com.apptrial.backend.credits.api

import com.apptrial.backend.credits.service.CreditWalletService
import com.apptrial.backend.shared.web.SecurityUtils
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

data class WalletResponse(
	val availableBalance: Int,
	val reservedBalance: Int,
)

@RestController
@RequestMapping("/api/v1/wallet")
class WalletController(
	private val creditWalletService: CreditWalletService,
) {
	@GetMapping
	fun wallet(): WalletResponse {
		val wallet = creditWalletService.getWallet(SecurityUtils.currentUser().id)
		return WalletResponse(
			availableBalance = wallet.availableBalance,
			reservedBalance = wallet.reservedBalance,
		)
	}
}
