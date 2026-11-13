import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tester_groups/data/groups_repository.dart';
import '../../tester_groups/presentation/my_groups_screen.dart';
import '../data/campaigns_repository.dart';
import '../domain/campaign_models.dart';

final exploreCampaignsProvider =
    FutureProvider.autoDispose<List<CampaignItem>>((ref) {
  return ref.watch(campaignsRepositoryProvider).explore();
});

class ExploreCampaignsScreen extends ConsumerWidget {
  const ExploreCampaignsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCampaigns = ref.watch(exploreCampaignsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar campañas'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () => ref.invalidate(exploreCampaignsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: asyncCampaigns.when(
        data: (campaigns) {
          if (campaigns.isEmpty) {
            return const Center(
              child: Text('No hay campañas en reclutamiento por ahora.'),
            );
          }
          return ListView.separated(
            itemCount: campaigns.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final c = campaigns[index];
              return ListTile(
                title: Text(c.name),
                subtitle: Text(
                  '${c.applicationName ?? 'App'} · ${c.durationDays} días · '
                  '${c.targetTesters} plazas · ${c.status}',
                ),
                trailing: FilledButton.tonal(
                  onPressed: () async {
                    try {
                      final group = await ref
                          .read(groupsRepositoryProvider)
                          .joinCampaign(c.id);
                      ref.invalidate(myGroupsProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Unido a ${group.name} (${group.occupiedSeats}/${group.targetSize})',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No se pudo unir: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Unirme'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
