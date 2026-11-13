import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../data/ai_repository.dart';

final aiInsightsProvider = FutureProvider.autoDispose
    .family<AiCampaignInsights, String>((ref, campaignId) {
  return ref.watch(aiRepositoryProvider).campaignInsights(campaignId);
});

class AiInsightsScreen extends ConsumerWidget {
  const AiInsightsScreen({
    super.key,
    required this.campaignId,
    required this.campaignName,
  });

  final String campaignId;
  final String campaignName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(aiInsightsProvider(campaignId));
    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.aiInsights} · $campaignName'),
        actions: [
          IconButton(
            tooltip: l10n.refresh,
            onPressed: () => ref.invalidate(aiInsightsProvider(campaignId)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: async.when(
        data: (insights) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              l10n.modeLabel(insights.mode),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 16),
            Text(l10n.summary, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(insights.feedbackSummary),
            const SizedBox(height: 24),
            Text(l10n.clusters, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (insights.issueClusters.isEmpty)
              Text(l10n.noClusters)
            else
              ...insights.issueClusters.map(
                (c) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.bubble_chart_outlined),
                  title: Text(c),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              l10n.suggestedImprovements,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...insights.suggestedImprovements.map(
              (c) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lightbulb_outline),
                title: Text(c),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              insights.disclaimer,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorWithDetails('$e'))),
      ),
    );
  }
}
