package com.apptrial.backend.campaigns.service

import com.apptrial.backend.shared.error.ValidationApiException

object CampaignPricing {
	private val costByDuration = mapOf(
		7 to 12,
		14 to 20,
		30 to 30,
	)

	fun costPerTesterTc(durationDays: Int): Int =
		costByDuration[durationDays]
			?: throw ValidationApiException(
				"Unsupported campaign duration",
				listOf("Supported durations: 7, 14, 30 days"),
			)
}
