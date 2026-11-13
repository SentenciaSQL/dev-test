import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../administration/presentation/admin_screen.dart';
import '../../analytics/presentation/analytics_screen.dart';
import '../../applications/presentation/applications_screen.dart';
import '../../authentication/presentation/auth_controller.dart';
import '../../billing/presentation/billing_screen.dart';
import '../../campaigns/data/campaigns_repository.dart';
import '../../campaigns/presentation/explore_campaigns_screen.dart';
import '../../campaigns/presentation/my_campaigns_screen.dart';
import '../../feedback/presentation/feedback_screen.dart';
import '../../missions/presentation/missions_hub_screen.dart';
import '../../notifications/presentation/notification_prefs_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../tester_groups/presentation/my_groups_screen.dart';
import '../../wallet/presentation/wallet_screen.dart';
import 'profile_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final isDeveloper = user?.isDeveloper ?? false;
    final isTester = user?.isTester ?? false;

    final pages = <Widget>[
      _HomeDashboard(
        displayName: user?.displayName ?? '',
        isDeveloper: isDeveloper,
        isTester: isTester,
      ),
      if (isTester) const ExploreCampaignsScreen() else const MyCampaignsScreen(),
      const MissionsHubScreen(),
      const WalletScreen(),
      const ProfileScreen(),
    ];

    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'Inicio',
      ),
      NavigationDestination(
        icon: Icon(isTester ? Icons.explore_outlined : Icons.campaign_outlined),
        selectedIcon: Icon(isTester ? Icons.explore_rounded : Icons.campaign_rounded),
        label: isTester ? 'Explorar' : 'Campañas',
      ),
      const NavigationDestination(
        icon: Icon(Icons.flag_outlined),
        selectedIcon: Icon(Icons.flag_rounded),
        label: 'Misiones',
      ),
      const NavigationDestination(
        icon: Icon(Icons.account_balance_wallet_outlined),
        selectedIcon: Icon(Icons.account_balance_wallet_rounded),
        label: 'Wallet',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded),
        label: 'Perfil',
      ),
    ];

    final safeIndex = _index.clamp(0, pages.length - 1);

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(
          key: ValueKey(safeIndex),
          child: pages[safeIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: destinations,
      ),
    );
  }
}

class _HomeDashboard extends ConsumerWidget {
  const _HomeDashboard({
    required this.displayName,
    required this.isDeveloper,
    required this.isTester,
  });

  final String displayName;
  final bool isDeveloper;
  final bool isTester;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final isAdmin = user?.isAdmin ?? false;
    final walletAsync = ref.watch(walletProvider);
    final campaignsAsync = ref.watch(
      isTester ? exploreCampaignsHomeProvider : myCampaignsHomeProvider,
    );

    return Scaffold(
      body: AppScaffoldBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(walletProvider);
              ref.invalidate(myCampaignsHomeProvider);
              ref.invalidate(exploreCampaignsHomeProvider);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            displayName,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.notifications_outlined),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: () async {
                        await ref.read(authControllerProvider.notifier).logout();
                        if (context.mounted) context.go('/login');
                      },
                      icon: const Icon(Icons.logout_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                walletAsync.when(
                  data: (w) => CreditBalanceCard(
                    available: w.availableBalance,
                    reserved: w.reservedBalance,
                    onBuy: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const BillingScreen()),
                    ),
                  ),
                  loading: () => const AppCard(child: LinearProgressIndicator()),
                  error: (_, _) => const AppCard(
                    child: Text('No se pudo cargar el wallet'),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(
                  title: 'Accesos rápidos',
                  subtitle: 'Lo que más usas, a un toque',
                ),
                const SizedBox(height: AppSpacing.sm),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 0.92,
                  children: [
                    if (isDeveloper)
                      QuickActionTile(
                        icon: Icons.apps_rounded,
                        label: 'Apps',
                        color: AppColors.primary,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ApplicationsScreen(),
                          ),
                        ),
                      ),
                    if (isTester)
                      QuickActionTile(
                        icon: Icons.groups_rounded,
                        label: 'Grupos',
                        color: AppColors.accent,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const MyGroupsScreen(),
                          ),
                        ),
                      ),
                    QuickActionTile(
                      icon: Icons.analytics_outlined,
                      label: 'Analíticas',
                      color: AppColors.highlight,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AnalyticsScreen(),
                        ),
                      ),
                    ),
                    QuickActionTile(
                      icon: Icons.feedback_outlined,
                      label: 'Feedback',
                      color: AppColors.warning,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const FeedbackScreen(),
                        ),
                      ),
                    ),
                    QuickActionTile(
                      icon: Icons.tune_rounded,
                      label: 'Avisos',
                      color: AppColors.inkMuted,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const NotificationPrefsScreen(),
                        ),
                      ),
                    ),
                    if (isAdmin)
                      QuickActionTile(
                        icon: Icons.admin_panel_settings_outlined,
                        label: 'Admin',
                        color: AppColors.error,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AdminScreen(),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(
                  title: isTester ? 'Campañas abiertas' : 'Tus campañas',
                  subtitle: isTester
                      ? 'Únete y empieza a probar'
                      : 'Estado de reclutamiento y progreso',
                ),
                const SizedBox(height: AppSpacing.sm),
                campaignsAsync.when(
                  data: (campaigns) {
                    if (campaigns.isEmpty) {
                      return EmptyState(
                        icon: Icons.campaign_outlined,
                        title: isTester ? 'Nada por explorar' : 'Sin campañas aún',
                        message: isTester
                            ? 'Cuando haya campañas en reclutamiento aparecerán aquí.'
                            : 'Crea tu primera campaña desde la pestaña Campañas.',
                      );
                    }
                    return Column(
                      children: campaigns.take(4).map((c) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: CampaignCard(
                            title: c.name,
                            subtitle: c.applicationName ?? c.applicationId,
                            status: c.status,
                            meta: [
                              '${c.durationDays} días',
                              '${c.targetTesters} testers',
                              '${c.costPerTesterTc} TC/plaza',
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const LoadingState(),
                  error: (e, _) => ErrorState(message: '$e'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }
}

final myCampaignsHomeProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(campaignsRepositoryProvider).listMine();
});

final exploreCampaignsHomeProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(campaignsRepositoryProvider).explore();
});
