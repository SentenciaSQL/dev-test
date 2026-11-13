import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/language_selector.dart';
import '../data/notifications_repository.dart';

final notificationPrefsProvider =
    FutureProvider.autoDispose<Map<String, bool>>((ref) {
  return ref.watch(notificationsRepositoryProvider).getPreferences();
});

class NotificationPrefsScreen extends ConsumerStatefulWidget {
  const NotificationPrefsScreen({super.key});

  @override
  ConsumerState<NotificationPrefsScreen> createState() =>
      _NotificationPrefsScreenState();
}

class _NotificationPrefsScreenState
    extends ConsumerState<NotificationPrefsScreen> {
  Map<String, bool>? _local;
  var _saving = false;

  static const _keys = [
    'all',
    'CAMPAIGN_PUBLISHED',
    'CAMPAIGN_JOINED',
    'GROUP_READY',
    'MISSION_APPROVED',
    'CREDITS_CHANGED',
  ];

  (String, String) _labels(AppLocalizations l10n, String key) {
    return switch (key) {
      'all' => (l10n.prefAll, l10n.prefAllSubtitle),
      'CAMPAIGN_PUBLISHED' => (
          l10n.prefCampaignPublished,
          l10n.prefCampaignPublishedSubtitle,
        ),
      'CAMPAIGN_JOINED' => (
          l10n.prefCampaignJoined,
          l10n.prefCampaignJoinedSubtitle,
        ),
      'GROUP_READY' => (l10n.prefGroupReady, l10n.prefGroupReadySubtitle),
      'MISSION_APPROVED' => (
          l10n.prefMissionApproved,
          l10n.prefMissionApprovedSubtitle,
        ),
      'CREDITS_CHANGED' => (
          l10n.prefCreditsChanged,
          l10n.prefCreditsChangedSubtitle,
        ),
      _ => (key, ''),
    };
  }

  IconData _iconFor(String key) {
    return switch (key) {
      'all' => Icons.notifications_active_outlined,
      'CAMPAIGN_PUBLISHED' => Icons.campaign_outlined,
      'CAMPAIGN_JOINED' => Icons.person_add_alt_1_outlined,
      'GROUP_READY' => Icons.groups_outlined,
      'MISSION_APPROVED' => Icons.verified_outlined,
      'CREDITS_CHANGED' => Icons.account_balance_wallet_outlined,
      _ => Icons.tune_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final asyncPrefs = ref.watch(notificationPrefsProvider);
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
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.preferences,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            l10n.preferencesSubtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: asyncPrefs.when(
                  data: (prefs) {
                    _local ??= Map<String, bool>.from(prefs);
                    final current = _local!;
                    return ListView(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        AppSpacing.xl,
                      ),
                      children: [
                        SectionHeader(
                          title: l10n.languageSection,
                          subtitle: l10n.languageSectionSubtitle,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.currentLanguage,
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              const LanguageSelector(),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SectionHeader(
                          title: l10n.developerTools,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppCard(
                          onTap: () async {
                            final token =
                                'mock-fcm-${DateTime.now().millisecondsSinceEpoch}';
                            await ref
                                .read(notificationsRepositoryProvider)
                                .registerPushToken(token);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context.l10n.tokenRegistered(token),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.phonelink_setup_outlined,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.registerMockFcm,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    Text(
                                      l10n.registerMockFcmSubtitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SectionHeader(
                          title: l10n.notificationsSection,
                          subtitle: l10n.notificationsSectionSubtitle,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              for (var i = 0; i < _keys.length; i++) ...[
                                if (i > 0)
                                  const Divider(height: 1, indent: 72),
                                Builder(
                                  builder: (context) {
                                    final key = _keys[i];
                                    final (title, subtitle) =
                                        _labels(l10n, key);
                                    final enabled = current[key] ?? true;
                                    return SwitchListTile(
                                      contentPadding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                        AppSpacing.md,
                                        4,
                                        AppSpacing.sm,
                                        4,
                                      ),
                                      secondary: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0F3F8),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          _iconFor(key),
                                          size: 20,
                                          color: AppColors.inkMuted,
                                        ),
                                      ),
                                      title: Text(title),
                                      subtitle: subtitle.isEmpty
                                          ? null
                                          : Text(subtitle),
                                      value: enabled,
                                      onChanged: _saving
                                          ? null
                                          : (v) {
                                              setState(() => current[key] = v);
                                            },
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        PrimaryButton(
                          label: _saving ? l10n.saving : l10n.save,
                          loading: _saving,
                          onPressed: _saving
                              ? null
                              : () async {
                                  setState(() => _saving = true);
                                  try {
                                    final saved = await ref
                                        .read(notificationsRepositoryProvider)
                                        .updatePreferences(current);
                                    setState(() {
                                      _local = saved;
                                      _saving = false;
                                    });
                                    ref.invalidate(notificationPrefsProvider);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text(context.l10n.preferencesSaved),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setState(() => _saving = false);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            context.l10n
                                                .errorWithDetails('$e'),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                        ),
                      ],
                    );
                  },
                  loading: () => const LoadingState(),
                  error: (e, _) => ErrorState(
                    message: context.l10n.errorWithDetails('$e'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
