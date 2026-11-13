import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../authentication/presentation/auth_controller.dart';
import '../data/analytics_repository.dart';

final developerAnalyticsProvider =
    FutureProvider.autoDispose<DeveloperAnalytics>((ref) {
  return ref.watch(analyticsRepositoryProvider).mine();
});

final platformAnalyticsProvider =
    FutureProvider.autoDispose<PlatformAnalytics>((ref) {
  return ref.watch(analyticsRepositoryProvider).platform();
});

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final mine = ref.watch(developerAnalyticsProvider);
    final isAdmin = user?.isAdmin ?? false;

    return Scaffold(
      body: AppScaffoldBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Text('Analíticas', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const SectionHeader(
                title: 'Mi resumen',
                subtitle: 'Actividad de tus apps y campañas',
              ),
              const SizedBox(height: AppSpacing.sm),
              mine.when(
                data: (a) => GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1.35,
                  children: [
                    StatCard(label: 'Apps', value: '${a.applications}', icon: Icons.apps_rounded),
                    StatCard(
                      label: 'Campañas activas',
                      value: '${a.activeCampaigns}',
                      icon: Icons.campaign_rounded,
                      tone: BadgeTone.accent,
                    ),
                    StatCard(
                      label: 'Plazas',
                      value: '${a.occupiedSeats}/${a.totalTargetTesters}',
                      icon: Icons.groups_rounded,
                    ),
                    StatCard(
                      label: 'Aprobados',
                      value: '${a.approvedSubmissions}',
                      icon: Icons.verified_rounded,
                      tone: BadgeTone.success,
                    ),
                    StatCard(
                      label: 'Feedback',
                      value: '${a.feedbackReports}',
                      icon: Icons.feedback_outlined,
                      tone: BadgeTone.warning,
                    ),
                    StatCard(
                      label: 'Créditos',
                      value: '${a.availableCredits}',
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                  ],
                ),
                loading: () => const LoadingState(),
                error: (e, _) => ErrorState(message: '$e'),
              ),
              if (isAdmin) ...[
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(
                  title: 'Plataforma',
                  subtitle: 'Vista admin',
                ),
                const SizedBox(height: AppSpacing.sm),
                Consumer(
                  builder: (context, ref, _) {
                    final platform = ref.watch(platformAnalyticsProvider);
                    return platform.when(
                      data: (p) => GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: AppSpacing.sm,
                        crossAxisSpacing: AppSpacing.sm,
                        childAspectRatio: 1.35,
                        children: [
                          StatCard(label: 'Usuarios', value: '${p.users}'),
                          StatCard(label: 'Developers', value: '${p.developers}'),
                          StatCard(label: 'Testers', value: '${p.testers}'),
                          StatCard(label: 'Campañas', value: '${p.campaigns}'),
                        ],
                      ),
                      loading: () => const LoadingState(),
                      error: (e, _) => ErrorState(message: '$e'),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
