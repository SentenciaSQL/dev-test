package com.apptrial.backend.aiassistant.service

import com.apptrial.backend.aiassistant.domain.AiUsageLogEntity
import com.apptrial.backend.aiassistant.domain.AiUsageLogRepository
import com.apptrial.backend.campaigns.domain.CampaignRepository
import com.apptrial.backend.feedback.domain.FeedbackReportRepository
import com.apptrial.backend.shared.error.ForbiddenException
import com.apptrial.backend.shared.error.NotFoundException
import com.apptrial.backend.shared.security.UserPrincipal
import org.slf4j.LoggerFactory
import org.springframework.ai.chat.client.ChatClient
import org.springframework.beans.factory.ObjectProvider
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

data class AiCampaignInsights(
	val campaignId: String,
	val mode: String,
	val feedbackSummary: String,
	val issueClusters: List<String>,
	val suggestedImprovements: List<String>,
	val disclaimer: String = "AI assists review; it does not replace human decisions.",
)

@Service
class AiAssistantService(
	private val campaignRepository: CampaignRepository,
	private val feedbackRepository: FeedbackReportRepository,
	private val aiUsageLogRepository: AiUsageLogRepository,
	private val chatClientProvider: ObjectProvider<ChatClient>,
	@Value("\${apptrial.ai.enabled:true}") private val aiEnabled: Boolean,
	@Value("\${apptrial.ai.max-input-chars:8000}") private val maxInputChars: Int,
) {
	private val log = LoggerFactory.getLogger(javaClass)

	@Transactional
	fun campaignInsights(campaignId: UUID, principal: UserPrincipal): AiCampaignInsights {
		val campaign = campaignRepository.findById(campaignId)
			.orElseThrow { NotFoundException("Campaign not found") }
		if (campaign.createdByUserId != principal.id && "ADMIN" !in principal.roles) {
			throw ForbiddenException("Not campaign owner")
		}

		val feedback = feedbackRepository.findAllByCampaignIdOrderByCreatedAtDesc(campaignId)
		val feedbackBlob = feedback.take(40).joinToString("\n") {
			"- [${it.reportType}/${it.severity ?: "-"}] ${it.title}: ${it.body}"
		}.take(maxInputChars)

		val chatClient = chatClientProvider.getIfAvailable()
		if (!aiEnabled || chatClient == null || feedbackBlob.isBlank()) {
			val result = heuristic(campaignId, feedbackBlob, feedback.size)
			recordUsage(principal.id, campaignId, result.mode, feedbackBlob.length)
			return result
		}

		return try {
			val prompt = """
				You help Android app developers triage beta testing feedback.
				Summarize themes, cluster similar issues, and suggest improvements.
				Do not invent bugs. Keep bullets short.
				Feedback:
				$feedbackBlob
			""".trimIndent()
			val answer = chatClient.prompt().user(prompt).call().content().orEmpty()
			val result = AiCampaignInsights(
				campaignId = campaignId.toString(),
				mode = "SPRING_AI_OPENAI",
				feedbackSummary = answer.take(2000),
				issueClusters = extractBullets(answer, "cluster"),
				suggestedImprovements = extractBullets(answer, "improv"),
			)
			recordUsage(principal.id, campaignId, result.mode, feedbackBlob.length)
			result
		} catch (ex: Exception) {
			log.warn("Spring AI call failed, falling back to heuristic: {}", ex.message)
			val result = heuristic(campaignId, feedbackBlob, feedback.size)
			recordUsage(principal.id, campaignId, result.mode, feedbackBlob.length)
			result
		}
	}

	private fun recordUsage(userId: UUID, campaignId: UUID, mode: String, inputChars: Int) {
		aiUsageLogRepository.save(
			AiUsageLogEntity(
				userId = userId,
				campaignId = campaignId,
				mode = mode,
				inputChars = inputChars,
			),
		)
	}

	private fun heuristic(campaignId: UUID, blob: String, count: Int): AiCampaignInsights {
		val keywords = listOf("crash", "login", "ui", "slow", "battery", "permission", "anr")
		val clusters = keywords.filter { blob.contains(it, ignoreCase = true) }
			.map { "Mentions of '$it'" }
			.ifEmpty { listOf("General feedback ($count reports)") }
		return AiCampaignInsights(
			campaignId = campaignId.toString(),
			mode = "HEURISTIC",
			feedbackSummary = if (count == 0) {
				"No feedback yet for this campaign."
			} else {
				"Processed $count feedback items locally without an LLM call."
			},
			issueClusters = clusters,
			suggestedImprovements = listOf(
				"Ask testers for repro steps on top clusters",
				"Prioritize crashes and login blockers before polish",
			),
		)
	}

	private fun extractBullets(text: String, hint: String): List<String> =
		text.lines()
			.map { it.trim().removePrefix("-").removePrefix("*").trim() }
			.filter { it.length in 8..160 }
			.filter {
				hint == "cluster" && it.contains("issue", true) ||
					hint == "improv" && (it.contains("should", true) || it.contains("consider", true)) ||
					true
			}
			.distinct()
			.take(5)
}
