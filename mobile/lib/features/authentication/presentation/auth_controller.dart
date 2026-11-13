import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../domain/auth_models.dart';

class AuthState {
  const AuthState({
    this.user,
    this.loading = false,
    this.error,
    this.initialized = false,
  });

  final AuthUser? user;
  final bool loading;
  final String? error;
  final bool initialized;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AuthUser? user,
    bool? loading,
    String? error,
    bool? initialized,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      initialized: initialized ?? this.initialized,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(const AuthState()) {
    bootstrap();
  }

  final AuthRepository _repository;

  Future<void> bootstrap() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      if (await _repository.hasSession()) {
        final user = await _repository.me();
        state = AuthState(user: user, initialized: true);
      } else {
        state = const AuthState(initialized: true);
      }
    } catch (_) {
      await _repository.logout();
      state = const AuthState(initialized: true);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final session = await _repository.login(email: email, password: password);
      state = AuthState(user: session.user, initialized: true);
    } catch (e) {
      state = state.copyWith(loading: false, error: _message(e));
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    required Set<String> roles,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      await _repository.register(
        email: email,
        password: password,
        displayName: displayName,
        roles: roles,
      );
      await login(email, password);
    } catch (e) {
      state = state.copyWith(loading: false, error: _message(e));
      rethrow;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(initialized: true);
  }

  String _message(Object e) => e.toString().replaceFirst('Exception: ', '');
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});
