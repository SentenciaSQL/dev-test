package com.apptrial.backend.credits.domain

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "credit_reservations")
class CreditReservationEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(name = "wallet_id", nullable = false)
	var walletId: UUID,
	@Column(name = "campaign_id", nullable = false)
	var campaignId: UUID,
	@Column(name = "amount_tc", nullable = false)
	var amountTc: Int,
	@Column(nullable = false)
	var status: String = "OPEN",
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
	@Column(name = "updated_at", nullable = false)
	var updatedAt: Instant = Instant.now(),
)
