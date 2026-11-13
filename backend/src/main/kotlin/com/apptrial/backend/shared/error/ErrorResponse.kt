package com.apptrial.backend.shared.error

data class ErrorResponse(
	val code: String,
	val message: String,
	val details: List<String> = emptyList(),
)
