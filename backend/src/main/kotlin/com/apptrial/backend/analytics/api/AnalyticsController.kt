package com.apptrial.backend.analytics.api

import com.apptrial.backend.analytics.service.AnalyticsService
import com.apptrial.backend.analytics.service.DeveloperAnalytics
import com.apptrial.backend.analytics.service.PlatformAnalytics
import com.apptrial.backend.shared.web.SecurityUtils
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/v1/analytics")
class AnalyticsController(
	private val analyticsService: AnalyticsService,
) {
	@GetMapping("/me")
	fun mine(): DeveloperAnalytics =
		analyticsService.developerOverview(SecurityUtils.currentUser().id)

	@GetMapping("/platform")
	fun platform(): PlatformAnalytics =
		analyticsService.platformOverview(SecurityUtils.currentUser())
}
