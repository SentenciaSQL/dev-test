import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../administration/presentation/admin_screen.dart';
import '../../analytics/presentation/analytics_screen.dart';
import '../../applications/presentation/applications_screen.dart';
import '../../authentication/presentation/auth_controller.dart';
import '../../billing/presentation/billing_screen.dart';
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
      const NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Inicio'),
      NavigationDestination(
        icon: Icon(isTester ? Icons.explore_outlined : Icons.campaign_outlined),
        label: isTester ? 'Explorar' : 'Campañas',
      ),
      const NavigationDestination(icon: Icon(Icons.flag_outlined), label: 'Misiones'),
      const NavigationDestination(
        icon: Icon(Icons.account_balance_wallet_outlined),
        label: 'Wallet',
      ),
      const NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
    ];

    final safeIndex = _index.clamp(0, pages.length - 1);

    return Scaffold(
      body: pages[safeIndex],
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('AppTrial'),
        actions: [
          IconButton(
            tooltip: 'Notificaciones',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const NotificationsScreen(),
              ),
            ),
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Hola, $displayName',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Roles: ${user?.roles.join(', ') ?? '-'}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text(
            'Fases 7–9: notificaciones FCM, analíticas, Spring AI, admin, SSE y auditoría.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          if (isDeveloper)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.apps_outlined),
              title: const Text('Mis aplicaciones'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ApplicationsScreen()),
              ),
            ),
          if (isTester)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.groups_outlined),
              title: const Text('Mis grupos'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const MyGroupsScreen()),
              ),
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.analytics_outlined),
            title: const Text('Analíticas'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AnalyticsScreen()),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Preferencias de notificación'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const NotificationPrefsScreen(),
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Feedback'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const FeedbackScreen()),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.shopping_cart_outlined),
            title: const Text('Comprar créditos / planes'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const BillingScreen()),
            ),
          ),
          if (isAdmin)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: const Text('Administración'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AdminScreen()),
              ),
            ),
        ],
      ),
    );
  }
}
