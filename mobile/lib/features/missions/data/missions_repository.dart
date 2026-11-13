import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/mission_models.dart';

class MissionsRepository {
  MissionsRepository(this._dio);

  final Dio _dio;

  Future<List<MissionItem>> listForCampaign(String campaignId) async {
    final response = await _dio.get<List<dynamic>>('/campaigns/$campaignId/missions');
    return (response.data ?? const [])
        .map((e) => MissionItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MissionItem> create({
    required String campaignId,
    required String title,
    required String missionType,
    int rewardTc = 1,
    bool evidenceRequired = true,
    String? description,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/campaigns/$campaignId/missions',
      data: {
        'title': title,
        'missionType': missionType,
        'rewardTc': rewardTc,
        'evidenceRequired': evidenceRequired,
        'description': description,
      },
    );
    return MissionItem.fromJson(response.data!);
  }

  Future<SubmissionItem> submit({
    required String missionId,
    String? description,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/missions/$missionId/submissions',
      data: {'description': description},
    );
    return SubmissionItem.fromJson(response.data!);
  }

  Future<List<SubmissionItem>> mySubmissions() async {
    final response = await _dio.get<List<dynamic>>('/me/submissions');
    return (response.data ?? const [])
        .map((e) => SubmissionItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<SubmissionItem>> listSubmissions(String missionId) async {
    final response = await _dio.get<List<dynamic>>('/missions/$missionId/submissions');
    return (response.data ?? const [])
        .map((e) => SubmissionItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SubmissionItem> review({
    required String submissionId,
    required String status,
    String? notes,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/submissions/$submissionId/review',
      data: {'status': status, 'reviewerNotes': notes},
    );
    return SubmissionItem.fromJson(response.data!);
  }

  Future<void> attachEvidenceText({
    required String submissionId,
    required String text,
  }) async {
    final upload = await _dio.post<Map<String, dynamic>>(
      '/submissions/$submissionId/evidence-uploads',
      data: {
        'contentType': 'text/plain',
        'sizeBytes': text.length,
      },
    );
    final uploadUrl = upload.data!['uploadUrl'] as String;
    final path = Uri.parse(uploadUrl).path.replaceFirst('/api/v1', '');
    await _dio.put<void>(
      path,
      data: text,
      options: Options(headers: {'Content-Type': 'text/plain'}),
    );
  }
}

final missionsRepositoryProvider = Provider<MissionsRepository>((ref) {
  return MissionsRepository(ref.watch(dioProvider));
});
