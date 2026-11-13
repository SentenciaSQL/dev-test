import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
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
      body: AppScaffoldBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Text('Mis grupos', style: Theme.of(context).textTheme.titleLarge),
                    ),
                    IconButton(
                      onPressed: () => ref.invalidate(myGroupsProvider),
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: asyncGroups.when(
                  data: (groups) {
                    if (groups.isEmpty) {
                      return const EmptyState(
                        icon: Icons.groups_outlined,
                        title: 'Todavía no estás en un grupo',
                        message: 'Explora campañas abiertas y únete para empezar.',
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: groups.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final g = groups[index];
                        final progress = g.targetSize == 0
                            ? 0.0
                            : g.occupiedSeats / g.targetSize;
                        return AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${g.campaignName ?? 'Campaña'} · ${g.name}',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ),
                                  StatusBadge(label: g.status, tone: toneForStatus(g.status)),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: progress.clamp(0, 1),
                                  minHeight: 8,
                                  backgroundColor: AppColors.border,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${g.occupiedSeats}/${g.targetSize} plazas · Tu estado: ${g.myMembershipStatus ?? '—'}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: _MemberActions(group: g),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const LoadingState(),
                  error: (e, _) => ErrorState(message: '$e'),
                ),
              ),
            ],
          ),
        ),
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
