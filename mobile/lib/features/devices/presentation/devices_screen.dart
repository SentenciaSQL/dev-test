import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../data/devices_repository.dart';

final devicesProvider = FutureProvider.autoDispose<List<DeviceItem>>((ref) {
  return ref.watch(devicesRepositoryProvider).list();
});

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final asyncDevices = ref.watch(devicesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.devicesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.registerDevice),
      ),
      body: asyncDevices.when(
        data: (devices) {
          if (devices.isEmpty) {
            return Center(child: Text(l10n.noDevicesYet));
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
        error: (e, _) => Center(child: Text(l10n.errorWithDetails('$e'))),
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
      builder: (context) {
        final l10n = context.l10n;
        return AlertDialog(
          title: Text(l10n.registerDevice),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fingerprint,
                decoration: InputDecoration(labelText: l10n.fingerprint),
              ),
              TextField(
                controller: model,
                decoration: InputDecoration(labelText: l10n.model),
              ),
              TextField(
                controller: manufacturer,
                decoration: InputDecoration(labelText: l10n.manufacturer),
              ),
              TextField(
                controller: androidVersion,
                decoration: InputDecoration(labelText: l10n.androidVersion),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.save),
            ),
          ],
        );
      },
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
