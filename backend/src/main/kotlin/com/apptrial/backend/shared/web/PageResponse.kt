package com.apptrial.backend.shared.web

data class PageResponse<T>(
	val items: List<T>,
	val page: Int,
	val size: Int,
	val totalElements: Long,
	val totalPages: Int,
)
