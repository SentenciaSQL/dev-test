package com.apptrial.backend.shared.security

import com.apptrial.backend.shared.config.AppProperties
import io.jsonwebtoken.Claims
import io.jsonwebtoken.Jwts
import io.jsonwebtoken.security.Keys
import org.springframework.stereotype.Service
import java.nio.charset.StandardCharsets
import java.time.Instant
import java.util.Date
import java.util.UUID
import javax.crypto.SecretKey

@Service
class JwtService(
	private val props: AppProperties,
) {
	private val key: SecretKey by lazy {
		val secret = props.security.jwtSecret
		require(secret.length >= 32) { "JWT secret must be at least 32 characters" }
		Keys.hmacShaKeyFor(secret.toByteArray(StandardCharsets.UTF_8))
	}

	fun createAccessToken(userId: UUID, email: String, roles: Collection<String>): String {
		val now = Instant.now()
		val exp = now.plusSeconds(props.security.accessTokenMinutes * 60)
		return Jwts.builder()
			.subject(userId.toString())
			.claim("email", email)
			.claim("roles", roles.toList())
			.claim("typ", "access")
			.issuedAt(Date.from(now))
			.expiration(Date.from(exp))
			.signWith(key)
			.compact()
	}

	fun parse(token: String): Claims =
		Jwts.parser()
			.verifyWith(key)
			.build()
			.parseSignedClaims(token)
			.payload

	fun accessTokenTtlSeconds(): Long = props.security.accessTokenMinutes * 60
}
