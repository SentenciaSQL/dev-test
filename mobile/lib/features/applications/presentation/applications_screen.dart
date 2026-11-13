import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      appBar: AppBar(title: const Text('Mis aplicaciones')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Registrar'),
      ),
      body: asyncApps.when(
        data: (apps) {
          if (apps.isEmpty) {
            return const Center(
              child: Text('Registra tu primera app Android.'),
            );
          }
          return ListView.separated(
            itemCount: apps.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final app = apps[index];
              return ListTile(
                title: Text(app.name),
                subtitle: Text('${app.packageName}\n${app.status}'),
                isThreeLine: true,
                trailing: IconButton(
                  tooltip: 'Archivar',
                  icon: const Icon(Icons.archive_outlined),
                  onPressed: () async {
                    await ref.read(applicationsRepositoryProvider).archive(app.id);
                    ref.invalidate(applicationsProvider);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
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
