import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class DeviceItem {
  const DeviceItem({
    required this.id,
    required this.deviceFingerprint,
    required this.androidVersion,
    this.model,
    this.manufacturer,
    this.sdkInt,
    this.primary = false,
  });

  final String id;
  final String deviceFingerprint;
  final String androidVersion;
  final String? model;
  final String? manufacturer;
  final int? sdkInt;
  final bool primary;

  factory DeviceItem.fromJson(Map<String, dynamic> json) => DeviceItem(
        id: json['id'] as String,
        deviceFingerprint: json['deviceFingerprint'] as String,
        androidVersion: json['androidVersion'] as String,
        model: json['model'] as String?,
        manufacturer: json['manufacturer'] as String?,
        sdkInt: (json['sdkInt'] as num?)?.toInt(),
        primary: (json['primary'] as bool?) ?? false,
      );
}

class DevicesRepository {
  DevicesRepository(this._dio);

  final Dio _dio;

  Future<List<DeviceItem>> list() async {
    final response = await _dio.get<List<dynamic>>('/me/devices');
    return (response.data ?? const [])
        .map((e) => DeviceItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DeviceItem> add({
    required String fingerprint,
    required String androidVersion,
    String? model,
    String? manufacturer,
    int? sdkInt,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/me/devices',
      data: {
        'deviceFingerprint': fingerprint,
        'androidVersion': androidVersion,
        'model': model,
        'manufacturer': manufacturer,
        'sdkInt': sdkInt,
        'primary': true,
      },
    );
    return DeviceItem.fromJson(response.data!);
  }

  Future<void> remove(String id) async {
    await _dio.delete<void>('/me/devices/$id');
  }
}

final devicesRepositoryProvider = Provider<DevicesRepository>((ref) {
  return DevicesRepository(ref.watch(dioProvider));
});
