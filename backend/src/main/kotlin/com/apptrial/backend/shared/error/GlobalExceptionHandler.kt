package com.apptrial.backend.shared.error

import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.authentication.BadCredentialsException
import org.springframework.security.core.AuthenticationException
import org.springframework.web.bind.MethodArgumentNotValidException
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice

@RestControllerAdvice
class GlobalExceptionHandler {
	private val log = LoggerFactory.getLogger(javaClass)

	@ExceptionHandler(ApiException::class)
	fun handleApi(ex: ApiException): ResponseEntity<ErrorResponse> =
		ResponseEntity.status(ex.status).body(ErrorResponse(ex.code, ex.message, ex.details))

	@ExceptionHandler(MethodArgumentNotValidException::class)
	fun handleValidation(ex: MethodArgumentNotValidException): ResponseEntity<ErrorResponse> {
		val details = ex.bindingResult.fieldErrors.map { "${it.field}: ${it.defaultMessage}" }
		return ResponseEntity.badRequest().body(
			ErrorResponse("VALIDATION_ERROR", "Request validation failed", details),
		)
	}

	@ExceptionHandler(BadCredentialsException::class, AuthenticationException::class)
	fun handleAuth(ex: Exception): ResponseEntity<ErrorResponse> =
		ResponseEntity.status(HttpStatus.UNAUTHORIZED)
			.body(ErrorResponse("UNAUTHORIZED", "Invalid credentials"))

	@ExceptionHandler(Exception::class)
	fun handleGeneric(ex: Exception): ResponseEntity<ErrorResponse> {
		log.error("Unhandled error", ex)
		return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
			.body(ErrorResponse("INTERNAL_ERROR", "Unexpected server error"))
	}
}
