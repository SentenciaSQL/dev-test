import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../data/groups_repository.dart';
import '../domain/group_models.dart';

final campaignGroupsProvider = FutureProvider.autoDispose
    .family<List<CampaignGroupItem>, String>((ref, campaignId) {
  return ref.watch(groupsRepositoryProvider).listCampaignGroups(campaignId);
});

class CampaignGroupsScreen extends ConsumerWidget {
  const CampaignGroupsScreen({super.key, required this.campaignId, this.campaignName});

  final String campaignId;
  final String? campaignName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final asyncGroups = ref.watch(campaignGroupsProvider(campaignId));
    return Scaffold(
      appBar: AppBar(title: Text(campaignName ?? l10n.groups)),
      body: asyncGroups.when(
        data: (groups) {
          if (groups.isEmpty) {
            return Center(child: Text(l10n.noGroupsForCampaign));
          }
          return ListView.separated(
            itemCount: groups.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final g = groups[index];
              return ExpansionTile(
                title: Text(g.name),
                subtitle: Text(
                  '${g.status} · ${g.occupiedSeats}/${g.targetSize} · '
                  '${g.openSeats} ${l10n.seats}',
                ),
                children: [
                  if (g.members.isEmpty)
                    ListTile(title: Text(l10n.noVisibleMembers))
                  else
                    ...g.members.map(
                      (m) => ListTile(
                        dense: true,
                        title: Text(m.userId),
                        subtitle: Text(m.status),
                      ),
                    ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorWithDetails('$e'))),
      ),
    );
  }
}
