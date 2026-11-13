import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final campaignsAsync = ref.watch(_campaignsForMissionsProvider);
    final submissionsAsync = ref.watch(mySubmissionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Misiones')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Campañas', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          campaignsAsync.when(
            data: (campaigns) {
              if (campaigns.isEmpty) {
                return const Text('No hay campañas disponibles.');
              }
              return Column(
                children: campaigns
                    .map(
                      (c) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(c.name),
                        subtitle: Text(c.status),
                        trailing: const Icon(Icons.chevron_right),
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
                    )
                    .toList(),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
          ),
          const Divider(height: 32),
          Text('Mis envíos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          submissionsAsync.when(
            data: (items) {
              if (items.isEmpty) return const Text('Sin envíos todavía.');
              return Column(
                children: items
                    .map(
                      (s) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(s.status),
                        subtitle: Text(
                          '${s.description ?? 'Sin descripción'} · evidencias: ${s.evidenceCount}',
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.campaignName)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createMission(context),
        icon: const Icon(Icons.add),
        label: const Text('Misión'),
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
            return const Center(child: Text('Sin misiones. Crea la primera.'));
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
                      tooltip: 'Enviar',
                      icon: const Icon(Icons.upload_file_outlined),
                      onPressed: () => _submit(m),
                    ),
                    if (widget.isOwner)
                      IconButton(
                        tooltip: 'Revisar',
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
    final title = TextEditingController(text: 'Probar flujo principal');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva misión'),
        content: TextField(controller: title, decoration: const InputDecoration(labelText: 'Título')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Crear')),
        ],
      ),
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
            description: 'Completado desde AppTrial',
          );
      await ref.read(missionsRepositoryProvider).attachEvidenceText(
            submissionId: submission.id,
            text: 'Evidencia de prueba para ${mission.title}',
          );
      ref.invalidate(mySubmissionsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Misión enviada con evidencia')),
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
          const SnackBar(content: Text('Sin envíos para revisar')),
        );
        return;
      }
      final first = submissions.first;
      await ref.read(missionsRepositoryProvider).review(
            submissionId: first.id,
            status: 'APPROVED',
            notes: 'Aprobado en revisión',
          );
      ref.invalidate(mySubmissionsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aprobado ${first.id} (+${mission.rewardTc} TC)')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}
