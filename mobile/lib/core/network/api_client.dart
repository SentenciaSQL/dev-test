import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.readAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _tryRefresh(dio, storage);
          if (refreshed) {
            final req = error.requestOptions;
            final token = await storage.readAccessToken();
            req.headers['Authorization'] = 'Bearer $token';
            final response = await dio.fetch(req);
            return handler.resolve(response);
          }
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});

Future<bool> _tryRefresh(Dio dio, TokenStorage storage) async {
  final refresh = await storage.readRefreshToken();
  if (refresh == null || refresh.isEmpty) return false;
  try {
    final response = await Dio(
      BaseOptions(baseUrl: AppConfig.apiBaseUrl),
    ).post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refresh},
    );
    final data = response.data;
    if (data == null) return false;
    await storage.saveTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
    return true;
  } catch (_) {
    await storage.clear();
    return false;
  }
}
