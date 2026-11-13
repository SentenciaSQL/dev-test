package com.apptrial.backend.aiassistant.config

import org.springframework.ai.chat.client.ChatClient
import org.springframework.boot.autoconfigure.condition.ConditionalOnBean
import org.springframework.boot.autoconfigure.condition.ConditionalOnExpression
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class AiConfig {
	@Bean
	@ConditionalOnExpression("!'\${spring.ai.openai.api-key:}'.trim().isEmpty()")
	@ConditionalOnBean(ChatClient.Builder::class)
	fun chatClient(builder: ChatClient.Builder): ChatClient = builder.build()
}
