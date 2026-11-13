import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class AiCampaignInsights {
  const AiCampaignInsights({
    required this.campaignId,
    required this.mode,
    required this.feedbackSummary,
    required this.issueClusters,
    required this.suggestedImprovements,
    required this.disclaimer,
  });

  final String campaignId;
  final String mode;
  final String feedbackSummary;
  final List<String> issueClusters;
  final List<String> suggestedImprovements;
  final String disclaimer;

  factory AiCampaignInsights.fromJson(Map<String, dynamic> json) =>
      AiCampaignInsights(
        campaignId: json['campaignId'] as String,
        mode: json['mode'] as String,
        feedbackSummary: json['feedbackSummary'] as String,
        issueClusters: ((json['issueClusters'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        suggestedImprovements:
            ((json['suggestedImprovements'] as List?) ?? const [])
                .map((e) => e.toString())
                .toList(),
        disclaimer: (json['disclaimer'] as String?) ??
            'AI assists review; it does not replace human decisions.',
      );
}

class AiRepository {
  AiRepository(this._dio);

  final Dio _dio;

  Future<AiCampaignInsights> campaignInsights(String campaignId) async {
    final response = await _dio
        .get<Map<String, dynamic>>('/ai/campaigns/$campaignId/insights');
    return AiCampaignInsights.fromJson(response.data!);
  }
}

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository(ref.watch(dioProvider));
});
