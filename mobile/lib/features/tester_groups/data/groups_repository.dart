import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/group_models.dart';

class GroupsRepository {
  GroupsRepository(this._dio);

  final Dio _dio;

  Future<List<CampaignGroupItem>> listCampaignGroups(String campaignId) async {
    final response = await _dio.get<List<dynamic>>('/campaigns/$campaignId/groups');
    return _map(response.data);
  }

  Future<List<CampaignGroupItem>> myGroups() async {
    final response = await _dio.get<List<dynamic>>('/me/groups');
    return _map(response.data);
  }

  Future<CampaignGroupItem> joinCampaign(String campaignId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/campaigns/$campaignId/join',
    );
    return CampaignGroupItem.fromJson(response.data!);
  }

  Future<GroupMemberItem> updateMemberStatus({
    required String memberId,
    required String status,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/group-members/$memberId',
      data: {'status': status},
    );
    return GroupMemberItem(
      id: response.data!['id'] as String,
      userId: response.data!['userId'] as String,
      status: response.data!['status'] as String,
    );
  }

  List<CampaignGroupItem> _map(List<dynamic>? data) => (data ?? const [])
      .map((e) => CampaignGroupItem.fromJson(e as Map<String, dynamic>))
      .toList();
}

final groupsRepositoryProvider = Provider<GroupsRepository>((ref) {
  return GroupsRepository(ref.watch(dioProvider));
});
