package com.apptrial.backend.testergroups.service

object GroupSizing {
	/**
	 * Splits campaign target seats into group sizes.
	 * Prefers [defaultSize] chunks; remainder merges into the last group if below [minSize].
	 */
	fun split(targetTesters: Int, defaultSize: Int, minSize: Int): List<Int> {
		require(targetTesters >= minSize) { "targetTesters must be >= $minSize" }
		require(defaultSize >= minSize) { "defaultSize must be >= $minSize" }

		if (targetTesters <= defaultSize) {
			return listOf(targetTesters)
		}

		val sizes = mutableListOf<Int>()
		var remaining = targetTesters
		while (remaining > 0) {
			if (remaining <= defaultSize) {
				if (remaining < minSize && sizes.isNotEmpty()) {
					sizes[sizes.lastIndex] = sizes.last() + remaining
				} else {
					sizes += remaining
				}
				break
			}
			sizes += defaultSize
			remaining -= defaultSize
		}
		return sizes
	}
}
