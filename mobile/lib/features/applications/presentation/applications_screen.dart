import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../data/applications_repository.dart';
import '../domain/application_models.dart';

final applicationsProvider =
    FutureProvider.autoDispose<List<ApplicationItem>>((ref) {
  return ref.watch(applicationsRepositoryProvider).listMine();
});

class ApplicationsScreen extends ConsumerWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final asyncApps = ref.watch(applicationsProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.register),
      ),
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
                      child: Text(
                        l10n.myApplications,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: asyncApps.when(
                  data: (apps) {
                    if (apps.isEmpty) {
                      return EmptyState(
                        icon: Icons.apps_outage_outlined,
                        title: l10n.noAppsYet,
                        message: l10n.noAppsYetMessage,
                        actionLabel: l10n.register,
                        onAction: () => _showCreateDialog(context, ref),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        100,
                      ),
                      itemCount: apps.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final app = apps[index];
                        return AppCard(
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8EEFF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.android_rounded),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      app.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    Text(
                                      app.packageName,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              StatusBadge(
                                label: app.status,
                                tone: toneForStatus(app.status),
                              ),
                              IconButton(
                                tooltip: l10n.archive,
                                icon: const Icon(Icons.archive_outlined),
                                onPressed: () async {
                                  await ref
                                      .read(applicationsRepositoryProvider)
                                      .archive(app.id);
                                  ref.invalidate(applicationsProvider);
                                },
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

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final packageName = TextEditingController(text: 'com.example.app');
    final description = TextEditingController();
    final version = TextEditingController(text: '1.0.0');
    final formKey = GlobalKey<FormState>();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final l10n = context.l10n;
        final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.92,
                maxWidth: 560,
              ),
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusXl),
                ),
                clipBehavior: Clip.antiAlias,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            AppSpacing.lg,
                            AppSpacing.md,
                            AppSpacing.lg,
                            AppSpacing.md,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.registerApplication,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                l10n.registerApplicationSubtitle,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              _FormSection(
                                title: l10n.sectionBasicInfo,
                                hint: l10n.sectionBasicInfoHint,
                                children: [
                                  TextFormField(
                                    controller: name,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      labelText: l10n.name,
                                      prefixIcon: const Icon(
                                        Icons.badge_outlined,
                                      ),
                                    ),
                                    validator: (v) =>
                                        v == null || v.trim().length < 2
                                            ? l10n.required
                                            : null,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  TextFormField(
                                    controller: description,
                                    textInputAction: TextInputAction.next,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      labelText: l10n.description,
                                      alignLabelWithHint: true,
                                      prefixIcon: const Icon(
                                        Icons.notes_rounded,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              _FormSection(
                                title: l10n.sectionTechnical,
                                hint: l10n.sectionTechnicalHint,
                                children: [
                                  TextFormField(
                                    controller: packageName,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      labelText: l10n.packageName,
                                      prefixIcon: const Icon(
                                        Icons.inventory_2_outlined,
                                      ),
                                    ),
                                    validator: (v) =>
                                        v == null || !v.contains('.')
                                            ? l10n.invalidPackage
                                            : null,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  TextFormField(
                                    controller: version,
                                    textInputAction: TextInputAction.done,
                                    decoration: InputDecoration(
                                      labelText: l10n.version,
                                      prefixIcon: const Icon(
                                        Icons.tag_rounded,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppSpacing.lg,
                          AppSpacing.xs,
                          AppSpacing.lg,
                          AppSpacing.lg,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: Text(l10n.cancel),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              flex: 2,
                              child: FilledButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    Navigator.pop(context, true);
                                  }
                                },
                                child: Text(l10n.create),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (ok == true) {
      try {
        await ref.read(applicationsRepositoryProvider).create(
              name: name.text.trim(),
              packageName: packageName.text.trim(),
              description: description.text.trim().isEmpty
                  ? null
                  : description.text.trim(),
              currentVersion: version.text.trim(),
            );
        ref.invalidate(applicationsProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.couldNotCreateApp('$e')),
            ),
          );
        }
      }
    }

    name.dispose();
    packageName.dispose();
    description.dispose();
    version.dispose();
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.hint,
    required this.children,
  });

  final String title;
  final String hint;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 2),
          Text(hint, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}
