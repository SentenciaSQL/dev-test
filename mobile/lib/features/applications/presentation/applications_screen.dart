import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final asyncApps = ref.watch(applicationsProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Registrar'),
      ),
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
                      child: Text(
                        'Mis aplicaciones',
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
                        title: 'Sin apps todavía',
                        message: 'Registra tu primera app Android para crear campañas.',
                        actionLabel: 'Registrar',
                        onAction: () => _showCreateDialog(context, ref),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        100,
                      ),
                      itemCount: apps.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
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
                                    Text(app.name, style: Theme.of(context).textTheme.titleMedium),
                                    Text(app.packageName, style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              ),
                              StatusBadge(label: app.status, tone: toneForStatus(app.status)),
                              IconButton(
                                tooltip: 'Archivar',
                                icon: const Icon(Icons.archive_outlined),
                                onPressed: () async {
                                  await ref.read(applicationsRepositoryProvider).archive(app.id);
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

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar aplicación'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) =>
                      v == null || v.trim().length < 2 ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: packageName,
                  decoration: const InputDecoration(labelText: 'Package name'),
                  validator: (v) =>
                      v == null || !v.contains('.') ? 'Package inválido' : null,
                ),
                TextFormField(
                  controller: description,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 2,
                ),
                TextFormField(
                  controller: version,
                  decoration: const InputDecoration(labelText: 'Versión'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
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
            SnackBar(content: Text('No se pudo crear: $e')),
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
