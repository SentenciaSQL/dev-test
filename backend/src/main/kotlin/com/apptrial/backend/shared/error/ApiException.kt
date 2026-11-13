package com.apptrial.backend.shared.error

import org.springframework.http.HttpStatus

open class ApiException(
	val code: String,
	override val message: String,
	val status: HttpStatus = HttpStatus.BAD_REQUEST,
	val details: List<String> = emptyList(),
) : RuntimeException(message)

class NotFoundException(message: String = "Resource not found") :
	ApiException("NOT_FOUND", message, HttpStatus.NOT_FOUND)

class UnauthorizedException(message: String = "Unauthorized") :
	ApiException("UNAUTHORIZED", message, HttpStatus.UNAUTHORIZED)

class ForbiddenException(message: String = "Forbidden") :
	ApiException("FORBIDDEN", message, HttpStatus.FORBIDDEN)

class ConflictException(message: String) :
	ApiException("CONFLICT", message, HttpStatus.CONFLICT)

class ValidationApiException(message: String, details: List<String> = emptyList()) :
	ApiException("VALIDATION_ERROR", message, HttpStatus.BAD_REQUEST, details)
