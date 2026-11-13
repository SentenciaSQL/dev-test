package com.apptrial.backend.shared.sse

import org.springframework.stereotype.Component
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter
import java.io.IOException
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.CopyOnWriteArrayList

data class CampaignSseEvent(
	val type: String,
	val campaignId: String,
	val message: String,
	val payload: Map<String, Any?> = emptyMap(),
)

@Component
class CampaignEventHub {
	private val emitters = ConcurrentHashMap<UUID, CopyOnWriteArrayList<SseEmitter>>()

	fun subscribe(campaignId: UUID): SseEmitter {
		val emitter = SseEmitter(0L)
		emitters.computeIfAbsent(campaignId) { CopyOnWriteArrayList() }.add(emitter)
		emitter.onCompletion { remove(campaignId, emitter) }
		emitter.onTimeout { remove(campaignId, emitter) }
		emitter.onError { remove(campaignId, emitter) }
		try {
			emitter.send(
				SseEmitter.event()
					.name("connected")
					.data(mapOf("campaignId" to campaignId.toString())),
			)
		} catch (_: IOException) {
			remove(campaignId, emitter)
		}
		return emitter
	}

	fun publish(campaignId: UUID, event: CampaignSseEvent) {
		val list = emitters[campaignId] ?: return
		val dead = mutableListOf<SseEmitter>()
		list.forEach { emitter ->
			try {
				emitter.send(SseEmitter.event().name(event.type).data(event))
			} catch (_: Exception) {
				dead += emitter
			}
		}
		dead.forEach { remove(campaignId, it) }
	}

	private fun remove(campaignId: UUID, emitter: SseEmitter) {
		emitters[campaignId]?.remove(emitter)
	}
}
