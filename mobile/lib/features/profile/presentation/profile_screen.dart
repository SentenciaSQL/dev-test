import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../authentication/presentation/auth_controller.dart';
import '../../devices/presentation/devices_screen.dart';
import '../../notifications/presentation/notification_prefs_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    if (user == null) {
      return const Scaffold(body: LoadingState());
    }
    return Scaffold(
      body: AppScaffoldBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text('Perfil', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Row(
                  children: [
                    UserAvatar(name: user.displayName, size: 64),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            children: user.roles
                                .map((r) => StatusBadge(label: r, tone: BadgeTone.info))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Column(
                  children: [
                    _InfoRow(label: 'Email verificado', value: user.emailVerified ? 'Sí' : 'Pendiente'),
                    const Divider(height: 24),
                    _InfoRow(label: 'País', value: user.countryCode ?? '—'),
                    const Divider(height: 24),
                    _InfoRow(label: 'Idioma', value: user.locale),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const SectionHeader(title: 'Configuración'),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const DevicesScreen()),
                ),
                child: const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.phone_android_rounded),
                  title: Text('Dispositivos'),
                  trailing: Icon(Icons.chevron_right_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const NotificationPrefsScreen(),
                  ),
                ),
                child: const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.notifications_active_outlined),
                  title: Text('Preferencias de notificación'),
                  trailing: Icon(Icons.chevron_right_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SecondaryButton(
                label: 'Cerrar sesión',
                icon: Icons.logout_rounded,
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}
