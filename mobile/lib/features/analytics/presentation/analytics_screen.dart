import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      appBar: AppBar(title: const Text('Analíticas')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Mi resumen', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          mine.when(
            data: (a) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('Aplicaciones', '${a.applications}'),
                _row('Campañas', '${a.campaigns} (${a.activeCampaigns} activas)'),
                _row('Plazas', '${a.occupiedSeats}/${a.totalTargetTesters}'),
                _row('Misiones', '${a.missions}'),
                _row(
                  'Envíos',
                  '${a.submissions} (${a.approvedSubmissions} aprobados)',
                ),
                _row('Feedback', '${a.feedbackReports}'),
                _row(
                  'Créditos',
                  '${a.availableCredits} disp. / ${a.reservedCredits} res.',
                ),
              ],
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
          ),
          if (isAdmin) ...[
            const SizedBox(height: 32),
            Text(
              'Plataforma (admin)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Consumer(
              builder: (context, ref, _) {
                final platform = ref.watch(platformAnalyticsProvider);
                return platform.when(
                  data: (p) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _row('Usuarios', '${p.users}'),
                      _row('Developers', '${p.developers}'),
                      _row('Testers', '${p.testers}'),
                      _row('Campañas', '${p.campaigns}'),
                      _row('Envíos', '${p.submissions}'),
                      _row('Feedback', '${p.feedbackReports}'),
                    ],
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
