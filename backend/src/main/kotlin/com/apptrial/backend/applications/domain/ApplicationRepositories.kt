package com.apptrial.backend.applications.domain

import org.springframework.data.jpa.repository.JpaRepository
import java.util.UUID

interface ApplicationRepository : JpaRepository<ApplicationEntity, UUID> {
	fun findAllByOwnerUserIdOrderByCreatedAtDesc(ownerUserId: UUID): List<ApplicationEntity>
	fun findByIdAndOwnerUserId(id: UUID, ownerUserId: UUID): ApplicationEntity?
	fun existsByOwnerUserIdAndPackageNameIgnoreCase(ownerUserId: UUID, packageName: String): Boolean
	fun countByOwnerUserIdAndStatus(ownerUserId: UUID, status: String): Long
}

interface ApplicationScreenshotRepository : JpaRepository<ApplicationScreenshotEntity, UUID> {
	fun findAllByApplicationIdOrderBySortOrderAsc(applicationId: UUID): List<ApplicationScreenshotEntity>
	fun deleteAllByApplicationId(applicationId: UUID)
}
