import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/devices_repository.dart';

final devicesProvider = FutureProvider.autoDispose<List<DeviceItem>>((ref) {
  return ref.watch(devicesRepositoryProvider).list();
});

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDevices = ref.watch(devicesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Dispositivos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Registrar'),
      ),
      body: asyncDevices.when(
        data: (devices) {
          if (devices.isEmpty) {
            return const Center(child: Text('Aún no hay dispositivos registrados.'));
          }
          return ListView.separated(
            itemCount: devices.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final d = devices[index];
              return ListTile(
                title: Text(d.model ?? d.deviceFingerprint),
                subtitle: Text(
                  '${d.manufacturer ?? 'Android'} · ${d.androidVersion}'
                  '${d.sdkInt != null ? ' (SDK ${d.sdkInt})' : ''}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await ref.read(devicesRepositoryProvider).remove(d.id);
                    ref.invalidate(devicesProvider);
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

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final fingerprint = TextEditingController(
      text: 'device-${DateTime.now().millisecondsSinceEpoch}',
    );
    final model = TextEditingController(text: 'Pixel Emulator');
    final manufacturer = TextEditingController(text: 'Google');
    final androidVersion = TextEditingController(text: '14');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar dispositivo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: fingerprint, decoration: const InputDecoration(labelText: 'Fingerprint')),
            TextField(controller: model, decoration: const InputDecoration(labelText: 'Modelo')),
            TextField(controller: manufacturer, decoration: const InputDecoration(labelText: 'Fabricante')),
            TextField(controller: androidVersion, decoration: const InputDecoration(labelText: 'Android')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(devicesRepositoryProvider).add(
            fingerprint: fingerprint.text.trim(),
            androidVersion: androidVersion.text.trim(),
            model: model.text.trim(),
            manufacturer: manufacturer.text.trim(),
            sdkInt: 34,
          );
      ref.invalidate(devicesProvider);
    }

    fingerprint.dispose();
    model.dispose();
    manufacturer.dispose();
    androidVersion.dispose();
  }
}
