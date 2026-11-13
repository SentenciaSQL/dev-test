import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class FeedbackItem {
  const FeedbackItem({
    required this.id,
    required this.campaignId,
    required this.reportType,
    required this.title,
    required this.body,
    required this.status,
  });

  final String id;
  final String campaignId;
  final String reportType;
  final String title;
  final String body;
  final String status;

  factory FeedbackItem.fromJson(Map<String, dynamic> json) => FeedbackItem(
        id: json['id'] as String,
        campaignId: json['campaignId'] as String,
        reportType: json['reportType'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        status: json['status'] as String,
      );
}

class FeedbackRepository {
  FeedbackRepository(this._dio);

  final Dio _dio;

  Future<FeedbackItem> create({
    required String campaignId,
    required String title,
    required String body,
    String reportType = 'FEEDBACK',
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/campaigns/$campaignId/feedback',
      data: {
        'reportType': reportType,
        'title': title,
        'body': body,
      },
    );
    return FeedbackItem.fromJson(response.data!);
  }

  Future<List<FeedbackItem>> mine() async {
    final response = await _dio.get<List<dynamic>>('/me/feedback');
    return (response.data ?? const [])
        .map((e) => FeedbackItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FeedbackRepository(ref.watch(dioProvider));
});
