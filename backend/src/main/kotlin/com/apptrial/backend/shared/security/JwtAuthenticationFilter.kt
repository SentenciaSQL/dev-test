package com.apptrial.backend.shared.security

import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.http.HttpHeaders
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.stereotype.Component
import org.springframework.web.filter.OncePerRequestFilter
import java.util.UUID

@Component
class JwtAuthenticationFilter(
	private val jwtService: JwtService,
) : OncePerRequestFilter() {
	override fun doFilterInternal(
		request: HttpServletRequest,
		response: HttpServletResponse,
		filterChain: FilterChain,
	) {
		val header = request.getHeader(HttpHeaders.AUTHORIZATION)
		if (header != null && header.startsWith("Bearer ")) {
			val token = header.substring(7)
			try {
				val claims = jwtService.parse(token)
				if (claims["typ"] == "access") {
					@Suppress("UNCHECKED_CAST")
					val roles = (claims["roles"] as? Collection<String>)?.toSet().orEmpty()
					val principal = UserPrincipal(
						id = UUID.fromString(claims.subject),
						email = claims["email"] as String,
						roles = roles,
					)
					val auth = UsernamePasswordAuthenticationToken(principal, null, principal.authorities)
					SecurityContextHolder.getContext().authentication = auth
				}
			} catch (_: Exception) {
				SecurityContextHolder.clearContext()
			}
		}
		filterChain.doFilter(request, response)
	}
}
