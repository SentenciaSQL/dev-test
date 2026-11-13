import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/campaign_models.dart';

class CampaignsRepository {
  CampaignsRepository(this._dio);

  final Dio _dio;

  Future<List<CampaignItem>> listMine() async {
    final response = await _dio.get<List<dynamic>>('/campaigns');
    return _mapList(response.data);
  }

  Future<List<CampaignItem>> explore({String? country, int? sdkInt}) async {
    final query = <String, dynamic>{
      if (country != null && country.isNotEmpty) 'country': country,
    };
    if (sdkInt != null) {
      query['sdkInt'] = sdkInt;
    }
    final response = await _dio.get<List<dynamic>>(
      '/campaigns/explore',
      queryParameters: query,
    );
    return _mapList(response.data);
  }

  Future<CampaignItem> create({
    required String applicationId,
    required String name,
    required int durationDays,
    required int targetTesters,
    String? description,
    List<String> allowedCountries = const [],
    int? minAndroidSdk,
    int? maxAndroidSdk,
    String? instructions,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/campaigns',
      data: {
        'applicationId': applicationId,
        'name': name,
        'description': description,
        'durationDays': durationDays,
        'targetTesters': targetTesters,
        'allowedCountries': allowedCountries,
        'minAndroidSdk': minAndroidSdk,
        'maxAndroidSdk': maxAndroidSdk,
        'instructions': instructions,
        'testType': 'CLOSED',
      },
    );
    return CampaignItem.fromJson(response.data!);
  }

  Future<CampaignItem> publish(String id) async {
    final response = await _dio.post<Map<String, dynamic>>('/campaigns/$id/publish');
    return CampaignItem.fromJson(response.data!);
  }

  Future<CampaignItem> cancel(String id) async {
    final response = await _dio.post<Map<String, dynamic>>('/campaigns/$id/cancel');
    return CampaignItem.fromJson(response.data!);
  }

  List<CampaignItem> _mapList(List<dynamic>? data) => (data ?? const [])
      .map((e) => CampaignItem.fromJson(e as Map<String, dynamic>))
      .toList();
}

final campaignsRepositoryProvider = Provider<CampaignsRepository>((ref) {
  return CampaignsRepository(ref.watch(dioProvider));
});
