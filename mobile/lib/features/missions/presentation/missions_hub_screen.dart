import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../campaigns/data/campaigns_repository.dart';
import '../../campaigns/domain/campaign_models.dart';
import '../data/missions_repository.dart';
import '../domain/mission_models.dart';

final _campaignsForMissionsProvider =
    FutureProvider.autoDispose<List<CampaignItem>>((ref) async {
  final mine = await ref.watch(campaignsRepositoryProvider).listMine();
  final explore = await ref.watch(campaignsRepositoryProvider).explore();
  final map = <String, CampaignItem>{};
  for (final c in [...mine, ...explore]) {
    map[c.id] = c;
  }
  return map.values.toList();
});

final mySubmissionsProvider =
    FutureProvider.autoDispose<List<SubmissionItem>>((ref) {
  return ref.watch(missionsRepositoryProvider).mySubmissions();
});

class MissionsHubScreen extends ConsumerWidget {
  const MissionsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final campaignsAsync = ref.watch(_campaignsForMissionsProvider);
    final submissionsAsync = ref.watch(mySubmissionsProvider);

    return Scaffold(
      body: AppScaffoldBackground(
        child: SafeArea(
          child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(l10n.missionsTitle, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            l10n.missionsSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: l10n.campaignsSection),
          const SizedBox(height: AppSpacing.sm),
          campaignsAsync.when(
            data: (campaigns) {
              if (campaigns.isEmpty) {
                return EmptyState(
                  icon: Icons.flag_outlined,
                  title: l10n.noCampaignsAvailable,
                  message: l10n.noCampaignsAvailableMessage,
                );
              }
              return Column(
                children: campaigns
                    .map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: CampaignCard(
                          title: c.name,
                          subtitle: l10n.openMissions,
                          status: c.status,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => CampaignMissionsScreen(
                                campaignId: c.id,
                                campaignName: c.name,
                                isOwner: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text(l10n.errorWithDetails('$e')),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: l10n.mySubmissions),
          const SizedBox(height: AppSpacing.sm),
          submissionsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return EmptyState(
                  icon: Icons.inbox_outlined,
                  title: l10n.noSubmissions,
                  message: l10n.noSubmissionsMessage,
                );
              }
              return Column(
                children: items
                    .map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: AppCard(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.description ?? l10n.missionSubmission,
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                    Text(
                                      l10n.evidenceCount(s.evidenceCount),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              StatusBadge(
                                label: s.status,
                                tone: toneForStatus(s.status),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const LoadingState(),
            error: (e, _) => ErrorState(message: '$e'),
          ),
        ],
          ),
        ),
      ),
    );
  }
}

class CampaignMissionsScreen extends ConsumerStatefulWidget {
  const CampaignMissionsScreen({
    super.key,
    required this.campaignId,
    required this.campaignName,
    this.isOwner = false,
  });

  final String campaignId;
  final String campaignName;
  final bool isOwner;

  @override
  ConsumerState<CampaignMissionsScreen> createState() =>
      _CampaignMissionsScreenState();
}

class _CampaignMissionsScreenState extends ConsumerState<CampaignMissionsScreen> {
  Future<List<MissionItem>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= ref.read(missionsRepositoryProvider).listForCampaign(widget.campaignId);
  }

  void _reload() {
    _future = ref.read(missionsRepositoryProvider).listForCampaign(widget.campaignId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(widget.campaignName)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createMission(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.mission),
      ),
      body: FutureBuilder<List<MissionItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
            return const Center(child: CircularProgressIndicator());
          }
          final missions = snapshot.data!;
          if (missions.isEmpty) {
            return Center(child: Text(l10n.noMissionsCreateFirst));
          }
          return ListView.separated(
            itemCount: missions.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final m = missions[index];
              return ListTile(
                title: Text(m.title),
                subtitle: Text('${m.missionType} · ${m.rewardTc} TC · ${m.status}'),
                trailing: Wrap(
                  children: [
                    IconButton(
                      tooltip: l10n.submit,
                      icon: const Icon(Icons.upload_file_outlined),
                      onPressed: () => _submit(m),
                    ),
                    if (widget.isOwner)
                      IconButton(
                        tooltip: l10n.review,
                        icon: const Icon(Icons.rate_review_outlined),
                        onPressed: () => _review(m),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _createMission(BuildContext context) async {
    final title = TextEditingController(text: 'Test main flow');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = context.l10n;
        return AlertDialog(
          title: Text(l10n.newMission),
          content: TextField(
            controller: title,
            decoration: InputDecoration(labelText: l10n.missionTitle),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.create)),
          ],
        );
      },
    );
    if (ok == true) {
      await ref.read(missionsRepositoryProvider).create(
            campaignId: widget.campaignId,
            title: title.text.trim(),
            missionType: 'FUNCTIONAL',
            rewardTc: 2,
          );
      setState(_reload);
    }
    title.dispose();
  }

  Future<void> _submit(MissionItem mission) async {
    try {
      final submission = await ref.read(missionsRepositoryProvider).submit(
            missionId: mission.id,
            description: 'Completed from AppTrial',
          );
      await ref.read(missionsRepositoryProvider).attachEvidenceText(
            submissionId: submission.id,
            text: 'Test evidence for ${mission.title}',
          );
      ref.invalidate(mySubmissionsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.missionSubmitted)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _review(MissionItem mission) async {
    try {
      final submissions =
          await ref.read(missionsRepositoryProvider).listSubmissions(mission.id);
      if (!mounted) return;
      if (submissions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.noSubmissionsToReview)),
        );
        return;
      }
      final first = submissions.first;
      await ref.read(missionsRepositoryProvider).review(
            submissionId: first.id,
            status: 'APPROVED',
            notes: 'Approved in review',
          );
      ref.invalidate(mySubmissionsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.approvedWithReward(first.id, mission.rewardTc),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}
