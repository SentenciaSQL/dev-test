import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/groups_repository.dart';
import '../domain/group_models.dart';

final myGroupsProvider =
    FutureProvider.autoDispose<List<CampaignGroupItem>>((ref) {
  return ref.watch(groupsRepositoryProvider).myGroups();
});

class MyGroupsScreen extends ConsumerWidget {
  const MyGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncGroups = ref.watch(myGroupsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis grupos'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(myGroupsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: asyncGroups.when(
        data: (groups) {
          if (groups.isEmpty) {
            return const Center(
              child: Text('Aún no estás en ningún grupo. Explora campañas para unirte.'),
            );
          }
          return ListView.separated(
            itemCount: groups.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final g = groups[index];
              return ListTile(
                title: Text('${g.campaignName ?? 'Campaña'} · ${g.name}'),
                subtitle: Text(
                  '${g.status} · ${g.occupiedSeats}/${g.targetSize} plazas\n'
                  'Tu estado: ${g.myMembershipStatus ?? '—'}',
                ),
                isThreeLine: true,
                trailing: _MemberActions(group: g),
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

class _MemberActions extends ConsumerWidget {
  const _MemberActions({required this.group});

  final CampaignGroupItem group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberId = group.myMembershipId;
    final status = group.myMembershipStatus;
    if (memberId == null || status == null) return const SizedBox.shrink();

    Future<void> transition(String next) async {
      try {
        await ref.read(groupsRepositoryProvider).updateMemberStatus(
              memberId: memberId,
              status: next,
            );
        ref.invalidate(myGroupsProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo actualizar: $e')),
          );
        }
      }
    }

    return PopupMenuButton<String>(
      onSelected: transition,
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];
        if (status == 'ACCEPTED') {
          items.add(const PopupMenuItem(value: 'CONFIRMED', child: Text('Confirmar')));
          items.add(const PopupMenuItem(value: 'DROPPED', child: Text('Abandonar')));
        } else if (status == 'CONFIRMED') {
          items.add(const PopupMenuItem(value: 'ACTIVE', child: Text('Marcar activo')));
          items.add(const PopupMenuItem(value: 'DROPPED', child: Text('Abandonar')));
        } else if (status == 'ACTIVE') {
          items.add(const PopupMenuItem(value: 'DROPPED', child: Text('Abandonar')));
        }
        return items;
      },
    );
  }
}
