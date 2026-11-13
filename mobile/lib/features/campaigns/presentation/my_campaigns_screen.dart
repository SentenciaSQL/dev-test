import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
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
    final l10n = context.l10n;
    final asyncCampaigns = ref.watch(myCampaignsProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.newCampaign),
      ),
      body: AppScaffoldBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.myCampaignsTitle, style: Theme.of(context).textTheme.headlineSmall),
                    Text(
                      l10n.myCampaignsSubtitle,
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
                        title: l10n.stillNoCampaigns,
                        message: l10n.stillNoCampaignsMessage,
                        actionLabel: l10n.newCampaign,
                        onAction: () => _showCreateDialog(context, ref),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async => ref.invalidate(myCampaignsProvider),
                      child: ListView.separated(
                        padding: const EdgeInsetsDirectional.fromSTEB(
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
                              l10n.testersCount(c.targetTesters),
                              l10n.tcAmount(c.totalCostTc),
                              l10n.daysCount(c.durationDays),
                            ],
                            trailing: Wrap(
                              spacing: 4,
                              children: [
                                if (c.status != 'DRAFT')
                                  IconButton.filledTonal(
                                    tooltip: l10n.groupsTooltip,
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
                                  tooltip: l10n.aiInsightsTooltip,
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
                                    tooltip: l10n.sseTooltip,
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
                                    tooltip: l10n.publishTooltip,
                                    onPressed: () async {
                                      try {
                                        await ref
                                            .read(campaignsRepositoryProvider)
                                            .publish(c.id);
                                        ref.invalidate(myCampaignsProvider);
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(l10n.publishFailed('$e')),
                                            ),
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
                                    tooltip: l10n.cancelTooltip,
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
    final l10n = context.l10n;
    if (apps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.registerAppFirst)),
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
      builder: (context) {
        final dialogL10n = context.l10n;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(dialogL10n.newCampaignDialogTitle),
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
                      decoration: InputDecoration(labelText: dialogL10n.application),
                    ),
                    TextFormField(
                      controller: name,
                      decoration: InputDecoration(labelText: dialogL10n.name),
                      validator: (v) =>
                          v == null || v.trim().length < 2 ? dialogL10n.required : null,
                    ),
                    TextFormField(
                      controller: description,
                      decoration: InputDecoration(labelText: dialogL10n.description),
                      maxLines: 2,
                    ),
                    DropdownButtonFormField<int>(
                      initialValue: durationDays,
                      items: [
                        DropdownMenuItem(value: 7, child: Text(dialogL10n.duration7)),
                        DropdownMenuItem(value: 14, child: Text(dialogL10n.duration14)),
                        DropdownMenuItem(value: 30, child: Text(dialogL10n.duration30)),
                      ],
                      onChanged: (v) => setState(() => durationDays = v ?? 14),
                      decoration: InputDecoration(labelText: dialogL10n.duration),
                    ),
                    TextFormField(
                      initialValue: '$targetTesters',
                      decoration: InputDecoration(
                        labelText: dialogL10n.targetTestersLabel,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => targetTesters = int.tryParse(v) ?? 15,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 12) return dialogL10n.minimum12;
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
                child: Text(dialogL10n.cancel),
              ),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context, true);
                  }
                },
                child: Text(dialogL10n.createDraft),
              ),
            ],
          ),
        );
      },
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
            SnackBar(content: Text(context.l10n.couldNotCreate('$e'))),
          );
        }
      }
    }

    name.dispose();
    description.dispose();
  }
}
