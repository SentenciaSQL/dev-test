package com.apptrial.backend.shared.audit

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table
import org.hibernate.annotations.JdbcTypeCode
import org.hibernate.type.SqlTypes
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "audit_logs")
class AuditLogEntity(
	@Id
	var id: UUID = UUID.randomUUID(),
	@Column(name = "actor_user_id")
	var actorUserId: UUID? = null,
	@Column(nullable = false)
	var action: String,
	@Column(name = "entity_type", nullable = false)
	var entityType: String,
	@Column(name = "entity_id")
	var entityId: UUID? = null,
	@Column(name = "ip_address")
	var ipAddress: String? = null,
	@JdbcTypeCode(SqlTypes.JSON)
	@Column(nullable = false, columnDefinition = "jsonb")
	var metadata: Map<String, Any?> = emptyMap(),
	@Column(name = "created_at", nullable = false)
	var createdAt: Instant = Instant.now(),
)

interface AuditLogRepository : JpaRepository<AuditLogEntity, UUID> {
	fun findAllByOrderByCreatedAtDesc(): List<AuditLogEntity>
	fun findAllByEntityTypeAndEntityIdOrderByCreatedAtDesc(entityType: String, entityId: UUID): List<AuditLogEntity>
}

@Service
class AuditService(
	private val auditLogRepository: AuditLogRepository,
) {
	@Transactional
	fun record(
		actorUserId: UUID?,
		action: String,
		entityType: String,
		entityId: UUID? = null,
		ipAddress: String? = null,
		metadata: Map<String, Any?> = emptyMap(),
	) {
		auditLogRepository.save(
			AuditLogEntity(
				actorUserId = actorUserId,
				action = action,
				entityType = entityType,
				entityId = entityId,
				ipAddress = ipAddress,
				metadata = metadata,
			),
		)
	}

	@Transactional(readOnly = true)
	fun recent(limit: Int = 100): List<AuditLogEntity> =
		auditLogRepository.findAllByOrderByCreatedAtDesc().take(limit)
}
