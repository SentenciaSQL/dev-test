import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final async = ref.watch(aiInsightsProvider(campaignId));
    return Scaffold(
      appBar: AppBar(
        title: Text('AI · $campaignName'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: () => ref.invalidate(aiInsightsProvider(campaignId)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: async.when(
        data: (insights) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Modo: ${insights.mode}',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 16),
            Text('Resumen', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(insights.feedbackSummary),
            const SizedBox(height: 24),
            Text('Clusters', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (insights.issueClusters.isEmpty)
              const Text('Sin clusters')
            else
              ...insights.issueClusters.map((c) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.bubble_chart_outlined),
                    title: Text(c),
                  )),
            const SizedBox(height: 16),
            Text(
              'Mejoras sugeridas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...insights.suggestedImprovements.map((c) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.lightbulb_outline),
                  title: Text(c),
                )),
            const SizedBox(height: 24),
            Text(
              insights.disclaimer,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
