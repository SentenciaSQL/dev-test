import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/auth_models.dart';

class AuthRepository {
  AuthRepository(this._dio, this._storage);

  final Dio _dio;
  final TokenStorage _storage;

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    required Set<String> roles,
  }) async {
    await _dio.post<void>(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'displayName': displayName,
        'roles': roles.toList(),
      },
    );
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final session = AuthSession.fromJson(response.data!);
    await _storage.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    return session;
  }

  Future<AuthUser> me() async {
    final response = await _dio.get<Map<String, dynamic>>('/me');
    return AuthUser.fromJson(response.data!);
  }

  Future<void> logout() async {
    final refresh = await _storage.readRefreshToken();
    if (refresh != null) {
      try {
        await _dio.post<void>('/auth/logout', data: {'refreshToken': refresh});
      } catch (_) {}
    }
    await _storage.clear();
  }

  Future<bool> hasSession() async {
    final token = await _storage.readAccessToken();
    return token != null && token.isNotEmpty;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider), ref.watch(tokenStorageProvider));
});
