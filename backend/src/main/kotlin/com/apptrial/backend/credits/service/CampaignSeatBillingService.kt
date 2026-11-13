package com.apptrial.backend.credits.service

import com.apptrial.backend.campaigns.domain.CampaignEntity
import com.apptrial.backend.credits.domain.CreditReservationRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

/**
 * Consumes reserved campaign credits when a tester seat is confirmed.
 */
@Service
class CampaignSeatBillingService(
	private val creditWalletService: CreditWalletService,
	private val reservationRepository: CreditReservationRepository,
) {
	@Transactional
	fun consumeSeat(campaign: CampaignEntity, memberId: UUID) {
		val reservation = reservationRepository.findByCampaignIdAndStatus(campaign.id, "OPEN")
			?: return
		val amount = campaign.costPerTesterTc
		if (amount <= 0 || reservation.amountTc < amount) return

		val ownerWallet = creditWalletService.getWallet(campaign.createdByUserId)
		creditWalletService.applyEntry(
			wallet = ownerWallet,
			entryType = "SPEND",
			amountTc = amount,
			idempotencyKey = "seat-spend:$memberId",
			referenceType = "GROUP_MEMBER",
			referenceId = memberId,
			metadata = mapOf("campaignId" to campaign.id.toString()),
		)

		reservation.amountTc -= amount
		reservation.updatedAt = Instant.now()
		if (reservation.amountTc == 0) {
			reservation.status = "CONSUMED"
		}
		reservationRepository.save(reservation)
	}

	@Transactional
	fun releaseSeatIfNeeded(campaign: CampaignEntity, memberId: UUID) {
		// Seat drops after spend are not automatically refunded in MVP.
		// Documented: refunds handled via admin adjustments.
	}
}
