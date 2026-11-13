import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class DeveloperAnalytics {
  const DeveloperAnalytics({
    required this.applications,
    required this.campaigns,
    required this.activeCampaigns,
    required this.totalTargetTesters,
    required this.occupiedSeats,
    required this.missions,
    required this.submissions,
    required this.approvedSubmissions,
    required this.feedbackReports,
    required this.availableCredits,
    required this.reservedCredits,
  });

  final int applications;
  final int campaigns;
  final int activeCampaigns;
  final int totalTargetTesters;
  final int occupiedSeats;
  final int missions;
  final int submissions;
  final int approvedSubmissions;
  final int feedbackReports;
  final int availableCredits;
  final int reservedCredits;

  factory DeveloperAnalytics.fromJson(Map<String, dynamic> json) =>
      DeveloperAnalytics(
        applications: (json['applications'] as num).toInt(),
        campaigns: (json['campaigns'] as num).toInt(),
        activeCampaigns: (json['activeCampaigns'] as num).toInt(),
        totalTargetTesters: (json['totalTargetTesters'] as num).toInt(),
        occupiedSeats: (json['occupiedSeats'] as num).toInt(),
        missions: (json['missions'] as num).toInt(),
        submissions: (json['submissions'] as num).toInt(),
        approvedSubmissions: (json['approvedSubmissions'] as num).toInt(),
        feedbackReports: (json['feedbackReports'] as num).toInt(),
        availableCredits: (json['availableCredits'] as num).toInt(),
        reservedCredits: (json['reservedCredits'] as num).toInt(),
      );
}

class PlatformAnalytics {
  const PlatformAnalytics({
    required this.users,
    required this.developers,
    required this.testers,
    required this.campaigns,
    required this.submissions,
    required this.feedbackReports,
  });

  final int users;
  final int developers;
  final int testers;
  final int campaigns;
  final int submissions;
  final int feedbackReports;

  factory PlatformAnalytics.fromJson(Map<String, dynamic> json) =>
      PlatformAnalytics(
        users: (json['users'] as num).toInt(),
        developers: (json['developers'] as num).toInt(),
        testers: (json['testers'] as num).toInt(),
        campaigns: (json['campaigns'] as num).toInt(),
        submissions: (json['submissions'] as num).toInt(),
        feedbackReports: (json['feedbackReports'] as num).toInt(),
      );
}

class AnalyticsRepository {
  AnalyticsRepository(this._dio);

  final Dio _dio;

  Future<DeveloperAnalytics> mine() async {
    final response = await _dio.get<Map<String, dynamic>>('/analytics/me');
    return DeveloperAnalytics.fromJson(response.data!);
  }

  Future<PlatformAnalytics> platform() async {
    final response =
        await _dio.get<Map<String, dynamic>>('/analytics/platform');
    return PlatformAnalytics.fromJson(response.data!);
  }
}

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(ref.watch(dioProvider));
});
