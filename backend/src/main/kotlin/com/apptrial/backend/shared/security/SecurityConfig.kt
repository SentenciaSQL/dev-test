package com.apptrial.backend.shared.security

import com.apptrial.backend.shared.config.AppProperties
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.HttpMethod
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter
import org.springframework.web.cors.CorsConfiguration
import org.springframework.web.cors.CorsConfigurationSource
import org.springframework.web.cors.UrlBasedCorsConfigurationSource

@Configuration
@EnableMethodSecurity
class SecurityConfig(
	private val jwtAuthenticationFilter: JwtAuthenticationFilter,
	private val props: AppProperties,
) {
	@Bean
	fun securityFilterChain(http: HttpSecurity): SecurityFilterChain {
		http
			.csrf { it.disable() }
			.cors { }
			.sessionManagement { it.sessionCreationPolicy(SessionCreationPolicy.STATELESS) }
			.authorizeHttpRequests {
				it.requestMatchers(
					"/api/v1/auth/**",
					"/actuator/health",
					"/actuator/info",
					"/v3/api-docs/**",
					"/swagger-ui/**",
				).permitAll()
				it.requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
				it.anyRequest().authenticated()
			}
			.addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter::class.java)
		return http.build()
	}

	@Bean
	fun corsConfigurationSource(): CorsConfigurationSource {
		val config = CorsConfiguration()
		val origins = props.cors.allowedOrigins.split(",").map { it.trim() }.filter { it.isNotEmpty() }
		if (origins.contains("*")) {
			config.allowedOriginPatterns = listOf("*")
		} else {
			config.allowedOrigins = origins
		}
		config.allowedMethods = listOf("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS")
		config.allowedHeaders = listOf("*")
		config.allowCredentials = true
		val source = UrlBasedCorsConfigurationSource()
		source.registerCorsConfiguration("/**", config)
		return source
	}
}
