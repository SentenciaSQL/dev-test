package com.apptrial.backend.users.domain

import org.springframework.data.jpa.repository.JpaRepository
import java.util.UUID

interface UserRepository : JpaRepository<UserEntity, UUID> {
	fun findByEmailIgnoreCase(email: String): UserEntity?
	fun existsByEmailIgnoreCase(email: String): Boolean
}

interface UserDeviceRepository : JpaRepository<UserDeviceEntity, UUID> {
	fun findAllByUserIdOrderByCreatedAtDesc(userId: UUID): List<UserDeviceEntity>
	fun findByIdAndUserId(id: UUID, userId: UUID): UserDeviceEntity?
	fun existsByUserIdAndDeviceFingerprint(userId: UUID, deviceFingerprint: String): Boolean
}

interface TesterProfileRepository : JpaRepository<TesterProfileEntity, UUID>
