import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../authentication/presentation/auth_controller.dart';
import '../../devices/presentation/devices_screen.dart';
import '../../notifications/presentation/notification_prefs_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(authControllerProvider).user;
    if (user == null) {
      return const Scaffold(body: LoadingState());
    }
    return Scaffold(
      body: AppScaffoldBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
            children: [
              Text(l10n.profile, style: Theme.of(context).textTheme.headlineSmall),
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
                    _InfoRow(
                      label: l10n.emailVerified,
                      value: user.emailVerified ? l10n.yes : l10n.pending,
                    ),
                    const Divider(height: 24),
                    _InfoRow(label: l10n.country, value: user.countryCode ?? '—'),
                    const Divider(height: 24),
                    _InfoRow(label: l10n.localeLabel, value: user.locale),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SectionHeader(title: l10n.settings),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const DevicesScreen()),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.phone_android_rounded),
                  title: Text(l10n.devices),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const NotificationPrefsScreen(),
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: Text(l10n.notificationPreferences),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SecondaryButton(
                label: l10n.signOut,
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
