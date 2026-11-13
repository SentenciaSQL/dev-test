package com.apptrial.backend.campaigns.domain

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table
import org.hibernate.annotations.JdbcTypeCode
import org.hibernate.type.SqlTypes
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "campaigns")
class CampaignEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(name = "application_id", nullable = false)
	var applicationId: UUID,
	@Column(name = "created_by_user_id", nullable = false)
	var createdByUserId: UUID,
	@Column(nullable = false)
	var name: String,
	@Column(columnDefinition = "text")
	var description: String? = null,
	@Column(name = "test_type", nullable = false)
	var testType: String = "CLOSED",
	@Column(name = "duration_days", nullable = false)
	var durationDays: Int,
	@Column(name = "starts_at")
	var startsAt: Instant? = null,
	@Column(name = "ends_at")
	var endsAt: Instant? = null,
	@Column(name = "target_testers", nullable = false)
	var targetTesters: Int = 15,
	@JdbcTypeCode(SqlTypes.ARRAY)
	@Column(name = "allowed_countries", nullable = false, columnDefinition = "bpchar(2)[]")
	var allowedCountries: Array<String> = emptyArray(),
	@Column(name = "min_android_sdk")
	var minAndroidSdk: Int? = null,
	@Column(name = "max_android_sdk")
	var maxAndroidSdk: Int? = null,
	@Column(columnDefinition = "text")
	var instructions: String? = null,
	@Column(nullable = false)
	var status: String = "DRAFT",
	@Column(name = "cost_per_tester_tc", nullable = false)
	var costPerTesterTc: Int,
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
	@Column(name = "updated_at", nullable = false)
	var updatedAt: Instant = Instant.now(),
) {
	fun totalCostTc(): Int = targetTesters * costPerTesterTc
}
