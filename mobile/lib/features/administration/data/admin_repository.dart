import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class AdminUser {
  const AdminUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.status,
    required this.roles,
    required this.reputationScore,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String displayName;
  final String status;
  final Set<String> roles;
  final double reputationScore;
  final String createdAt;

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String,
        status: json['status'] as String,
        roles: ((json['roles'] as List?) ?? const [])
            .map((e) => e.toString())
            .toSet(),
        reputationScore: (json['reputationScore'] as num).toDouble(),
        createdAt: json['createdAt'].toString(),
      );
}

class FraudSignalItem {
  const FraudSignalItem({
    required this.userId,
    required this.email,
    required this.signal,
    required this.detail,
  });

  final String userId;
  final String email;
  final String signal;
  final String detail;

  factory FraudSignalItem.fromJson(Map<String, dynamic> json) =>
      FraudSignalItem(
        userId: json['userId'] as String,
        email: json['email'] as String,
        signal: json['signal'] as String,
        detail: json['detail'] as String,
      );
}

class AuditLogItem {
  const AuditLogItem({
    required this.id,
    required this.action,
    required this.entityType,
    required this.createdAt,
    this.actorUserId,
    this.entityId,
    this.metadata = const {},
  });

  final String id;
  final String? actorUserId;
  final String action;
  final String entityType;
  final String? entityId;
  final String createdAt;
  final Map<String, dynamic> metadata;

  factory AuditLogItem.fromJson(Map<String, dynamic> json) => AuditLogItem(
        id: json['id'] as String,
        actorUserId: json['actorUserId']?.toString(),
        action: json['action'] as String,
        entityType: json['entityType'] as String,
        entityId: json['entityId']?.toString(),
        createdAt: json['createdAt'].toString(),
        metadata: Map<String, dynamic>.from(
          (json['metadata'] as Map?) ?? const {},
        ),
      );
}

class AdminRepository {
  AdminRepository(this._dio);

  final Dio _dio;

  Future<List<AdminUser>> users() async {
    final response = await _dio.get<List<dynamic>>('/admin/users');
    return (response.data ?? const [])
        .map((e) => AdminUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AdminUser> suspend(String userId, String reason) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/users/$userId/suspend',
      data: {'reason': reason},
    );
    return AdminUser.fromJson(response.data!);
  }

  Future<AdminUser> activate(String userId) async {
    final response = await _dio
        .post<Map<String, dynamic>>('/admin/users/$userId/activate');
    return AdminUser.fromJson(response.data!);
  }

  Future<void> adjustCredits({
    required String userId,
    required int amountTc,
    required String reason,
  }) async {
    await _dio.post(
      '/admin/users/$userId/credits/adjust',
      data: {'amountTc': amountTc, 'reason': reason},
    );
  }

  Future<List<FraudSignalItem>> fraudSignals() async {
    final response = await _dio.get<List<dynamic>>('/admin/fraud-signals');
    return (response.data ?? const [])
        .map((e) => FraudSignalItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AuditLogItem>> auditLogs({int limit = 100}) async {
    final response = await _dio.get<List<dynamic>>(
      '/admin/audit-logs',
      queryParameters: {'limit': limit},
    );
    return (response.data ?? const [])
        .map((e) => AuditLogItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(dioProvider));
});
