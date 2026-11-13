import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  Widget build(BuildContext context) {
    final asyncPrefs = ref.watch(notificationPrefsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Preferencias push')),
      body: asyncPrefs.when(
        data: (prefs) {
          _local ??= Map<String, bool>.from(prefs);
          final current = _local!;
          return ListView(
            children: [
              ListTile(
                title: const Text('Registrar token mock FCM'),
                subtitle: const Text(
                  'Guarda un token de desarrollo en el backend (modo MOCK).',
                ),
                trailing: const Icon(Icons.phonelink_setup_outlined),
                onTap: () async {
                  final token =
                      'mock-fcm-${DateTime.now().millisecondsSinceEpoch}';
                  await ref
                      .read(notificationsRepositoryProvider)
                      .registerPushToken(token);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Token registrado: $token')),
                    );
                  }
                },
              ),
              const Divider(),
              ..._keys.map((key) {
                final enabled = current[key] ?? true;
                return SwitchListTile(
                  title: Text(key),
                  value: enabled,
                  onChanged: _saving
                      ? null
                      : (v) {
                          setState(() => current[key] = v);
                        },
                );
              }),
              Padding(
                padding: const EdgeInsets.all(24),
                child: FilledButton(
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Preferencias guardadas'),
                                ),
                              );
                            }
                          } catch (e) {
                            setState(() => _saving = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                  child: Text(_saving ? 'Guardando…' : 'Guardar'),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
