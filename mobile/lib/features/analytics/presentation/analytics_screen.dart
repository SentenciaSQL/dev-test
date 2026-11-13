import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
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
    final l10n = context.l10n;
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
                  Text(
                    l10n.analyticsTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SectionHeader(
                title: l10n.mySummary,
                subtitle: l10n.mySummarySubtitle,
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
                    StatCard(
                      label: l10n.apps,
                      value: '${a.applications}',
                      icon: Icons.apps_rounded,
                    ),
                    StatCard(
                      label: l10n.activeCampaigns,
                      value: '${a.activeCampaigns}',
                      icon: Icons.campaign_rounded,
                      tone: BadgeTone.accent,
                    ),
                    StatCard(
                      label: l10n.seats,
                      value: '${a.occupiedSeats}/${a.totalTargetTesters}',
                      icon: Icons.groups_rounded,
                    ),
                    StatCard(
                      label: l10n.approved,
                      value: '${a.approvedSubmissions}',
                      icon: Icons.verified_rounded,
                      tone: BadgeTone.success,
                    ),
                    StatCard(
                      label: l10n.feedback,
                      value: '${a.feedbackReports}',
                      icon: Icons.feedback_outlined,
                      tone: BadgeTone.warning,
                    ),
                    StatCard(
                      label: l10n.credits,
                      value: '${a.availableCredits}',
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                  ],
                ),
                loading: () => const LoadingState(),
                error: (e, _) =>
                    ErrorState(message: l10n.errorWithDetails('$e')),
              ),
              if (isAdmin) ...[
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(
                  title: l10n.platform,
                  subtitle: l10n.platformSubtitle,
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
                          StatCard(label: l10n.users, value: '${p.users}'),
                          StatCard(
                            label: l10n.developers,
                            value: '${p.developers}',
                          ),
                          StatCard(
                            label: l10n.testers,
                            value: '${p.testers}',
                          ),
                          StatCard(
                            label: l10n.navCampaigns,
                            value: '${p.campaigns}',
                          ),
                        ],
                      ),
                      loading: () => const LoadingState(),
                      error: (e, _) =>
                          ErrorState(message: l10n.errorWithDetails('$e')),
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
