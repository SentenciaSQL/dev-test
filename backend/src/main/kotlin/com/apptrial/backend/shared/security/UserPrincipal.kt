package com.apptrial.backend.shared.security

import org.springframework.security.core.GrantedAuthority
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.core.userdetails.UserDetails
import java.util.UUID

data class UserPrincipal(
	val id: UUID,
	val email: String,
	val roles: Set<String>,
	private val active: Boolean = true,
) : UserDetails {
	override fun getAuthorities(): Collection<GrantedAuthority> =
		roles.map { SimpleGrantedAuthority("ROLE_$it") }

	override fun getPassword(): String? = null
	override fun getUsername(): String = email
	override fun isAccountNonExpired(): Boolean = true
	override fun isAccountNonLocked(): Boolean = active
	override fun isCredentialsNonExpired(): Boolean = true
	override fun isEnabled(): Boolean = active
}
