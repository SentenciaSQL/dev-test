import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/application_models.dart';

class ApplicationsRepository {
  ApplicationsRepository(this._dio);

  final Dio _dio;

  Future<List<ApplicationItem>> listMine() async {
    final response = await _dio.get<List<dynamic>>('/applications');
    return (response.data ?? const [])
        .map((e) => ApplicationItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ApplicationItem> create({
    required String name,
    required String packageName,
    String? description,
    String? category,
    String? currentVersion,
    String? closedTestingUrl,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/applications',
      data: {
        'name': name,
        'packageName': packageName,
        'description': description,
        'category': category,
        'currentVersion': currentVersion,
        'closedTestingUrl': closedTestingUrl,
      },
    );
    return ApplicationItem.fromJson(response.data!);
  }

  Future<void> archive(String id) async {
    await _dio.delete<void>('/applications/$id');
  }
}

final applicationsRepositoryProvider = Provider<ApplicationsRepository>((ref) {
  return ApplicationsRepository(ref.watch(dioProvider));
});
