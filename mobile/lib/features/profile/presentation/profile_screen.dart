import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/presentation/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        children: [
          ListTile(title: const Text('Nombre'), subtitle: Text(user.displayName)),
          ListTile(title: const Text('Email'), subtitle: Text(user.email)),
          ListTile(
            title: const Text('Email verificado'),
            subtitle: Text(user.emailVerified ? 'Sí' : 'Pendiente'),
          ),
          ListTile(title: const Text('País'), subtitle: Text(user.countryCode ?? '—')),
          ListTile(title: const Text('Idioma'), subtitle: Text(user.locale)),
          ListTile(title: const Text('Roles'), subtitle: Text(user.roles.join(', '))),
        ],
      ),
    );
  }
}
