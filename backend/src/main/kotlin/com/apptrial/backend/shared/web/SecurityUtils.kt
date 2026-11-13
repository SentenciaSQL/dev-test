package com.apptrial.backend.shared.web

import com.apptrial.backend.shared.error.UnauthorizedException
import com.apptrial.backend.shared.security.UserPrincipal
import org.springframework.security.core.context.SecurityContextHolder

object SecurityUtils {
	fun currentUser(): UserPrincipal {
		val auth = SecurityContextHolder.getContext().authentication
			?: throw UnauthorizedException()
		val principal = auth.principal
		if (principal is UserPrincipal) return principal
		throw UnauthorizedException()
	}
}
