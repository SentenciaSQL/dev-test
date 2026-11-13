import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../data/admin_repository.dart';

final adminUsersProvider =
    FutureProvider.autoDispose<List<AdminUser>>((ref) {
  return ref.watch(adminRepositoryProvider).users();
});

final fraudSignalsProvider =
    FutureProvider.autoDispose<List<FraudSignalItem>>((ref) {
  return ref.watch(adminRepositoryProvider).fraudSignals();
});

final auditLogsProvider =
    FutureProvider.autoDispose<List<AuditLogItem>>((ref) {
  return ref.watch(adminRepositoryProvider).auditLogs();
});

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final users = ref.watch(adminUsersProvider);
    final fraud = ref.watch(fraudSignalsProvider);
    final audit = ref.watch(auditLogsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.adminTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.usersTab),
              Tab(text: l10n.fraudTab),
              Tab(text: l10n.auditTab),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            users.when(
              data: (list) {
                if (list.isEmpty) {
                  return Center(child: Text(l10n.noUsers));
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final u = list[index];
                    return ListTile(
                      title: Text(u.displayName),
                      subtitle: Text(
                        '${u.email}\n${u.status} · ${u.roles.join(', ')} · rep ${u.reputationScore}',
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (action) async {
                          final repo = ref.read(adminRepositoryProvider);
                          try {
                            switch (action) {
                              case 'suspend':
                                await repo.suspend(u.id, 'Admin action');
                              case 'activate':
                                await repo.activate(u.id);
                              case 'credits':
                                await repo.adjustCredits(
                                  userId: u.id,
                                  amountTc: 10,
                                  reason: 'Admin grant +10',
                                );
                            }
                            ref.invalidate(adminUsersProvider);
                            ref.invalidate(auditLogsProvider);
                            ref.invalidate(fraudSignalsProvider);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context.l10n.errorWithDetails('$e'),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'suspend',
                            child: Text(l10n.suspend),
                          ),
                          PopupMenuItem(
                            value: 'activate',
                            child: Text(l10n.activate),
                          ),
                          PopupMenuItem(
                            value: 'credits',
                            child: Text(l10n.adjustCreditsPlus10),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(l10n.errorWithDetails('$e'))),
            ),
            fraud.when(
              data: (list) {
                if (list.isEmpty) {
                  return Center(child: Text(l10n.noFraudSignals));
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final s = list[index];
                    return ListTile(
                      title: Text(s.signal),
                      subtitle: Text('${s.email}\n${s.detail}'),
                      isThreeLine: true,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(l10n.errorWithDetails('$e'))),
            ),
            audit.when(
              data: (list) {
                if (list.isEmpty) {
                  return Center(child: Text(l10n.noAudit));
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final a = list[index];
                    return ListTile(
                      title: Text(a.action),
                      subtitle: Text(
                        '${a.entityType} ${a.entityId ?? '-'}\n${a.createdAt}',
                      ),
                      isThreeLine: true,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(l10n.errorWithDetails('$e'))),
            ),
          ],
        ),
      ),
    );
  }
}
