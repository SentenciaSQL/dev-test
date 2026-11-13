import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../tester_groups/data/groups_repository.dart';
import '../../tester_groups/presentation/my_groups_screen.dart';
import '../data/campaigns_repository.dart';
import '../domain/campaign_models.dart';

final exploreCampaignsProvider =
    FutureProvider.autoDispose<List<CampaignItem>>((ref) {
  return ref.watch(campaignsRepositoryProvider).explore();
});

class ExploreCampaignsScreen extends ConsumerStatefulWidget {
  const ExploreCampaignsScreen({super.key});

  @override
  ConsumerState<ExploreCampaignsScreen> createState() =>
      _ExploreCampaignsScreenState();
}

class _ExploreCampaignsScreenState extends ConsumerState<ExploreCampaignsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final asyncCampaigns = ref.watch(exploreCampaignsProvider);
    return Scaffold(
      body: AppScaffoldBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Explorar', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text(
                      'Campañas abiertas listas para unirte',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Buscar por nombre o app',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                      onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: asyncCampaigns.when(
                  data: (campaigns) {
                    final filtered = campaigns.where((c) {
                      if (_query.isEmpty) return true;
                      return c.name.toLowerCase().contains(_query) ||
                          (c.applicationName ?? '').toLowerCase().contains(_query);
                    }).toList();
                    if (filtered.isEmpty) {
                      return EmptyState(
                        icon: Icons.explore_off_outlined,
                        title: 'Sin resultados',
                        message: 'No hay campañas en reclutamiento con ese criterio.',
                        actionLabel: 'Actualizar',
                        onAction: () => ref.invalidate(exploreCampaignsProvider),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async => ref.invalidate(exploreCampaignsProvider),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.xs,
                          AppSpacing.lg,
                          AppSpacing.xl,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final c = filtered[index];
                          return CampaignCard(
                            title: c.name,
                            subtitle: c.applicationName ?? 'Aplicación',
                            status: c.status,
                            meta: [
                              '${c.durationDays} días',
                              '${c.targetTesters} plazas',
                              '${c.costPerTesterTc} TC',
                            ],
                            trailing: PrimaryButton(
                              label: 'Unirme',
                              icon: Icons.group_add_outlined,
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
                            ),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const LoadingState(),
                  error: (e, _) => ErrorState(
                    message: '$e',
                    onRetry: () => ref.invalidate(exploreCampaignsProvider),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
