import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
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
    final l10n = context.l10n;
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
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home_rounded),
        label: l10n.navHome,
      ),
      NavigationDestination(
        icon: Icon(isTester ? Icons.explore_outlined : Icons.campaign_outlined),
        selectedIcon: Icon(isTester ? Icons.explore_rounded : Icons.campaign_rounded),
        label: isTester ? l10n.navExplore : l10n.navCampaigns,
      ),
      NavigationDestination(
        icon: const Icon(Icons.flag_outlined),
        selectedIcon: const Icon(Icons.flag_rounded),
        label: l10n.navMissions,
      ),
      NavigationDestination(
        icon: const Icon(Icons.account_balance_wallet_outlined),
        selectedIcon: const Icon(Icons.account_balance_wallet_rounded),
        label: l10n.navWallet,
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline_rounded),
        selectedIcon: const Icon(Icons.person_rounded),
        label: l10n.navProfile,
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
    final l10n = context.l10n;
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
              padding: const EdgeInsetsDirectional.fromSTEB(
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
                            _greeting(l10n),
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
                  error: (_, _) => AppCard(
                    child: Text(l10n.walletCouldNotLoad),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(
                  title: l10n.quickActions,
                  subtitle: l10n.quickActionsSubtitle,
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
                        label: l10n.apps,
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
                        label: l10n.groups,
                        color: AppColors.accent,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const MyGroupsScreen(),
                          ),
                        ),
                      ),
                    QuickActionTile(
                      icon: Icons.analytics_outlined,
                      label: l10n.analytics,
                      color: AppColors.highlight,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AnalyticsScreen(),
                        ),
                      ),
                    ),
                    QuickActionTile(
                      icon: Icons.feedback_outlined,
                      label: l10n.feedback,
                      color: AppColors.warning,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const FeedbackScreen(),
                        ),
                      ),
                    ),
                    QuickActionTile(
                      icon: Icons.tune_rounded,
                      label: l10n.alerts,
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
                        label: l10n.admin,
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
                  title: isTester ? l10n.openCampaigns : l10n.yourCampaigns,
                  subtitle: isTester
                      ? l10n.openCampaignsSubtitle
                      : l10n.yourCampaignsSubtitle,
                ),
                const SizedBox(height: AppSpacing.sm),
                campaignsAsync.when(
                  data: (campaigns) {
                    if (campaigns.isEmpty) {
                      return EmptyState(
                        icon: Icons.campaign_outlined,
                        title: isTester ? l10n.nothingToExplore : l10n.noCampaignsYet,
                        message: isTester
                            ? l10n.nothingToExploreMessage
                            : l10n.noCampaignsYetMessage,
                      );
                    }
                    return Column(
                      children: campaigns.take(4).map((c) {
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(
                            bottom: AppSpacing.sm,
                          ),
                          child: CampaignCard(
                            title: c.name,
                            subtitle: c.applicationName ?? c.applicationId,
                            status: c.status,
                            meta: [
                              l10n.daysCount(c.durationDays),
                              l10n.testersCount(c.targetTesters),
                              l10n.tcPerSeat(c.costPerTesterTc),
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

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.greetingMorning;
    if (hour < 19) return l10n.greetingAfternoon;
    return l10n.greetingEvening;
  }
}

final myCampaignsHomeProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(campaignsRepositoryProvider).listMine();
});

final exploreCampaignsHomeProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(campaignsRepositoryProvider).explore();
});
