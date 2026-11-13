import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../ai_assistant/presentation/ai_insights_screen.dart';
import '../../applications/data/applications_repository.dart';
import '../../applications/domain/application_models.dart';
import '../../tester_groups/presentation/campaign_groups_screen.dart';
import '../data/campaigns_repository.dart';
import '../domain/campaign_models.dart';
import 'campaign_events_screen.dart';

final myCampaignsProvider =
    FutureProvider.autoDispose<List<CampaignItem>>((ref) {
  return ref.watch(campaignsRepositoryProvider).listMine();
});

class MyCampaignsScreen extends ConsumerWidget {
  const MyCampaignsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCampaigns = ref.watch(myCampaignsProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva campaña'),
      ),
      body: AppScaffoldBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    Text('Mis campañas', style: Theme.of(context).textTheme.headlineSmall),
                    Text(
                      'Borradores, reclutamiento y seguimiento',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: asyncCampaigns.when(
                  data: (campaigns) {
                    if (campaigns.isEmpty) {
                      return EmptyState(
                        icon: Icons.campaign_outlined,
                        title: 'Aún no tienes campañas',
                        message: 'Crea un borrador y publícalo para empezar a reclutar.',
                        actionLabel: 'Nueva campaña',
                        onAction: () => _showCreateDialog(context, ref),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async => ref.invalidate(myCampaignsProvider),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          100,
                        ),
                        itemCount: campaigns.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final c = campaigns[index];
                          return CampaignCard(
                            title: c.name,
                            subtitle: c.applicationName ?? c.applicationId,
                            status: c.status,
                            meta: [
                              '${c.targetTesters} testers',
                              '${c.totalCostTc} TC',
                              '${c.durationDays} días',
                            ],
                            trailing: Wrap(
                              spacing: 4,
                              children: [
                                if (c.status != 'DRAFT')
                                  IconButton.filledTonal(
                                    tooltip: 'Grupos',
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => CampaignGroupsScreen(
                                            campaignId: c.id,
                                            campaignName: c.name,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.groups_outlined),
                                  ),
                                IconButton.filledTonal(
                                  tooltip: 'AI insights',
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => AiInsightsScreen(
                                          campaignId: c.id,
                                          campaignName: c.name,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.auto_awesome_outlined),
                                ),
                                if (c.status != 'DRAFT')
                                  IconButton.filledTonal(
                                    tooltip: 'SSE',
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => CampaignEventsScreen(
                                            campaignId: c.id,
                                            campaignName: c.name,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.stream_outlined),
                                  ),
                                if (c.status == 'DRAFT')
                                  IconButton.filledTonal(
                                    tooltip: 'Publicar',
                                    onPressed: () async {
                                      try {
                                        await ref
                                            .read(campaignsRepositoryProvider)
                                            .publish(c.id);
                                        ref.invalidate(myCampaignsProvider);
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Publicar falló: $e')),
                                          );
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.publish_outlined),
                                  ),
                                if (c.status != 'CANCELLED' &&
                                    c.status != 'COMPLETED' &&
                                    c.status != 'EXPIRED')
                                  IconButton.filledTonal(
                                    tooltip: 'Cancelar',
                                    onPressed: () async {
                                      await ref
                                          .read(campaignsRepositoryProvider)
                                          .cancel(c.id);
                                      ref.invalidate(myCampaignsProvider);
                                    },
                                    icon: const Icon(Icons.cancel_outlined),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const LoadingState(),
                  error: (e, _) => ErrorState(
                    message: '$e',
                    onRetry: () => ref.invalidate(myCampaignsProvider),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    List<ApplicationItem> apps = const [];
    try {
      apps = await ref.read(applicationsRepositoryProvider).listMine();
    } catch (_) {}
    if (!context.mounted) return;
    if (apps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registra una aplicación primero')),
      );
      return;
    }

    var selectedApp = apps.first;
    final name = TextEditingController();
    final description = TextEditingController();
    var durationDays = 14;
    var targetTesters = 15;
    final formKey = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nueva campaña'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<ApplicationItem>(
                    initialValue: selectedApp,
                    items: apps
                        .map(
                          (a) => DropdownMenuItem(
                            value: a,
                            child: Text(a.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedApp = v ?? selectedApp),
                    decoration: const InputDecoration(labelText: 'Aplicación'),
                  ),
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (v) =>
                        v == null || v.trim().length < 2 ? 'Requerido' : null,
                  ),
                  TextFormField(
                    controller: description,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    maxLines: 2,
                  ),
                  DropdownButtonFormField<int>(
                    initialValue: durationDays,
                    items: const [
                      DropdownMenuItem(value: 7, child: Text('7 días (12 TC/tester)')),
                      DropdownMenuItem(value: 14, child: Text('14 días (20 TC/tester)')),
                      DropdownMenuItem(value: 30, child: Text('30 días (30 TC/tester)')),
                    ],
                    onChanged: (v) => setState(() => durationDays = v ?? 14),
                    decoration: const InputDecoration(labelText: 'Duración'),
                  ),
                  TextFormField(
                    initialValue: '$targetTesters',
                    decoration: const InputDecoration(
                      labelText: 'Testers objetivo (mín. 12, default 15)',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => targetTesters = int.tryParse(v) ?? 15,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 12) return 'Mínimo 12';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Crear borrador'),
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      try {
        await ref.read(campaignsRepositoryProvider).create(
              applicationId: selectedApp.id,
              name: name.text.trim(),
              description: description.text.trim().isEmpty
                  ? null
                  : description.text.trim(),
              durationDays: durationDays,
              targetTesters: targetTesters,
            );
        ref.invalidate(myCampaignsProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo crear: $e')),
          );
        }
      }
    }

    name.dispose();
    description.dispose();
  }
}
