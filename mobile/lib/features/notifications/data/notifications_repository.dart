import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.eventType,
    required this.title,
    required this.body,
    required this.createdAt,
    this.readAt,
    this.payload = const {},
  });

  final String id;
  final String eventType;
  final String title;
  final String body;
  final String? readAt;
  final String createdAt;
  final Map<String, dynamic> payload;

  bool get isUnread => readAt == null;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        eventType: json['eventType'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        readAt: json['readAt']?.toString(),
        createdAt: json['createdAt'].toString(),
        payload: Map<String, dynamic>.from(
          (json['payload'] as Map?) ?? const {},
        ),
      );
}

class NotificationsRepository {
  NotificationsRepository(this._dio);

  final Dio _dio;

  Future<List<AppNotification>> list() async {
    final response = await _dio.get<List<dynamic>>('/notifications');
    return (response.data ?? const [])
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> unreadCount() async {
    final response =
        await _dio.get<Map<String, dynamic>>('/notifications/unread-count');
    return (response.data?['unread'] as num?)?.toInt() ?? 0;
  }

  Future<void> markRead(String id) async {
    await _dio.post('/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _dio.post('/notifications/read-all');
  }

  Future<void> registerPushToken(String fcmToken) async {
    await _dio.post('/push-tokens', data: {
      'fcmToken': fcmToken,
      'platform': 'ANDROID',
    });
  }

  Future<Map<String, bool>> getPreferences() async {
    final response =
        await _dio.get<Map<String, dynamic>>('/me/notification-preferences');
    final raw = response.data ?? const {};
    return raw.map((k, v) => MapEntry(k, v == true));
  }

  Future<Map<String, bool>> updatePreferences(Map<String, bool> prefs) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/me/notification-preferences',
      data: {'preferences': prefs},
    );
    final raw = response.data ?? const {};
    return raw.map((k, v) => MapEntry(k, v == true));
  }
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref.watch(dioProvider));
});
