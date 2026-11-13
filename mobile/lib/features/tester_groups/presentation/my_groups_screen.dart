import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
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
    final l10n = context.l10n;
    final asyncGroups = ref.watch(myGroupsProvider);
    return Scaffold(
      body: AppScaffoldBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
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
                      child: Text(
                        l10n.myGroups,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
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
                      return EmptyState(
                        icon: Icons.groups_outlined,
                        title: l10n.notInGroupYet,
                        message: l10n.notInGroupYetMessage,
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: groups.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
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
                                      '${g.campaignName ?? l10n.navCampaigns} · ${g.name}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ),
                                  StatusBadge(
                                    label: g.status,
                                    tone: toneForStatus(g.status),
                                  ),
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
                                l10n.groupProgress(
                                  g.occupiedSeats,
                                  g.targetSize,
                                  g.myMembershipStatus ?? '—',
                                ),
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
                  error: (e, _) =>
                      ErrorState(message: l10n.errorWithDetails('$e')),
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
    final l10n = context.l10n;
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
            SnackBar(content: Text(context.l10n.couldNotUpdate('$e'))),
          );
        }
      }
    }

    return PopupMenuButton<String>(
      onSelected: transition,
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];
        if (status == 'ACCEPTED') {
          items.add(PopupMenuItem(value: 'CONFIRMED', child: Text(l10n.confirm)));
          items.add(PopupMenuItem(value: 'DROPPED', child: Text(l10n.leave)));
        } else if (status == 'CONFIRMED') {
          items.add(
            PopupMenuItem(value: 'ACTIVE', child: Text(l10n.markActive)),
          );
          items.add(PopupMenuItem(value: 'DROPPED', child: Text(l10n.leave)));
        } else if (status == 'ACTIVE') {
          items.add(PopupMenuItem(value: 'DROPPED', child: Text(l10n.leave)));
        }
        return items;
      },
    );
  }
}
