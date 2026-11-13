package com.apptrial.backend.applications.domain

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "applications")
class ApplicationEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(name = "owner_user_id", nullable = false)
	var ownerUserId: UUID,
	@Column(nullable = false)
	var name: String,
	var description: String? = null,
	@Column(name = "package_name", nullable = false)
	var packageName: String,
	@Column(name = "icon_url")
	var iconUrl: String? = null,
	var category: String? = null,
	@Column(name = "current_version")
	var currentVersion: String? = null,
	@Column(name = "play_store_url")
	var playStoreUrl: String? = null,
	@Column(name = "closed_testing_url")
	var closedTestingUrl: String? = null,
	var instructions: String? = null,
	@Column(nullable = false)
	var status: String = "ACTIVE",
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
	@Column(name = "updated_at", nullable = false)
	var updatedAt: Instant = Instant.now(),
)

@Entity
@Table(name = "application_screenshots")
class ApplicationScreenshotEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(name = "application_id", nullable = false)
	var applicationId: UUID,
	@Column(name = "image_url", nullable = false)
	var imageUrl: String,
	@Column(name = "sort_order", nullable = false)
	var sortOrder: Int = 0,
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
)
