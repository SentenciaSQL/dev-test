import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/auth_controller.dart';
import '../../features/authentication/presentation/login_screen.dart';
import '../../features/authentication/presentation/register_screen.dart';
import '../../features/profile/presentation/home_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      if (!auth.initialized) return null;
      final loggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      if (!auth.isAuthenticated && !loggingIn) return '/login';
      if (auth.isAuthenticated && loggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (_, _) => const HomeShell()),
    ],
  );
});

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(this._ref) {
    _ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;
}
