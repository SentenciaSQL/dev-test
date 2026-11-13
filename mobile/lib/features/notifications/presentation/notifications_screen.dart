import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../data/notifications_repository.dart';

final notificationsProvider =
    FutureProvider.autoDispose<List<AppNotification>>((ref) {
  return ref.watch(notificationsRepositoryProvider).list();
});

final unreadCountProvider = FutureProvider.autoDispose<int>((ref) {
  return ref.watch(notificationsRepositoryProvider).unreadCount();
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final asyncList = ref.watch(notificationsProvider);
    return Scaffold(
      body: AppScaffoldBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
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
                        l10n.notifications,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await ref.read(notificationsRepositoryProvider).markAllRead();
                        ref.invalidate(notificationsProvider);
                        ref.invalidate(unreadCountProvider);
                      },
                      child: Text(l10n.markAll),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: asyncList.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return EmptyState(
                        icon: Icons.notifications_none_rounded,
                        title: l10n.inboxEmpty,
                        message: l10n.inboxEmptyMessage,
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: items.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final n = items[index];
                        return AppCard(
                          accent: n.isUnread,
                          onTap: () async {
                            if (n.isUnread) {
                              await ref
                                  .read(notificationsRepositoryProvider)
                                  .markRead(n.id);
                              ref.invalidate(notificationsProvider);
                              ref.invalidate(unreadCountProvider);
                            }
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: n.isUnread
                                      ? AppColors.primarySoft
                                      : const Color(0xFFF0F3F8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  n.isUnread
                                      ? Icons.notifications_active_rounded
                                      : Icons.notifications_none_rounded,
                                  color: n.isUnread
                                      ? AppColors.primary
                                      : AppColors.inkFaint,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.title,
                                      style:
                                          Theme.of(context).textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      n.body,
                                      style:
                                          Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${n.eventType} · ${n.createdAt}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
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
