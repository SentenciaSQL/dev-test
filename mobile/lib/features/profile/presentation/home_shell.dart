import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../applications/presentation/applications_screen.dart';
import '../../authentication/presentation/auth_controller.dart';
import '../../campaigns/presentation/explore_campaigns_screen.dart';
import '../../campaigns/presentation/my_campaigns_screen.dart';
import '../../devices/presentation/devices_screen.dart';
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
      _HomeDashboard(displayName: user?.displayName ?? ''),
      if (isTester) const ExploreCampaignsScreen(),
      if (isTester) const MyGroupsScreen(),
      if (isDeveloper) const ApplicationsScreen(),
      if (isDeveloper) const MyCampaignsScreen(),
      if (isTester) const DevicesScreen(),
      const WalletScreen(),
      const ProfileScreen(),
    ];

    final destinations = <NavigationDestination>[
      const NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Inicio'),
      if (isTester)
        const NavigationDestination(icon: Icon(Icons.explore_outlined), label: 'Explorar'),
      if (isTester)
        const NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Grupos'),
      if (isDeveloper)
        const NavigationDestination(icon: Icon(Icons.apps_outlined), label: 'Apps'),
      if (isDeveloper)
        const NavigationDestination(icon: Icon(Icons.campaign_outlined), label: 'Campañas'),
      if (isTester)
        const NavigationDestination(icon: Icon(Icons.phone_android), label: 'Dispositivos'),
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
  const _HomeDashboard({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AppTrial'),
        actions: [
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
            'Fase 3: al publicar una campaña se crean grupos (default 15). '
            'Los testers se unen con asignación automática; pueden confirmar o abandonar.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
