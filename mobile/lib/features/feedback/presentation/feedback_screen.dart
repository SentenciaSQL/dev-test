import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../campaigns/data/campaigns_repository.dart';
import '../data/feedback_repository.dart';

final myFeedbackProvider = FutureProvider.autoDispose<List<FeedbackItem>>((ref) {
  return ref.watch(feedbackRepositoryProvider).mine();
});

class FeedbackScreen extends ConsumerWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFeedback = ref.watch(myFeedbackProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context, ref),
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('Nuevo'),
      ),
      body: asyncFeedback.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Aún no has enviado feedback.'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final f = items[index];
              return ListTile(
                title: Text(f.title),
                subtitle: Text('${f.reportType} · ${f.status}\n${f.body}'),
                isThreeLine: true,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final campaigns = await ref.read(campaignsRepositoryProvider).explore();
    final mine = await ref.read(campaignsRepositoryProvider).listMine();
    final all = [...mine, ...campaigns];
    if (!context.mounted) return;
    if (all.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Necesitas una campaña para enviar feedback')),
      );
      return;
    }
    var selected = all.first;
    final title = TextEditingController(text: 'Comentario de prueba');
    final body = TextEditingController(text: 'Detalle del feedback desde AppTrial');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Enviar feedback'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField(
                initialValue: selected,
                items: all
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => selected = v ?? selected),
                decoration: const InputDecoration(labelText: 'Campaña'),
              ),
              TextField(controller: title, decoration: const InputDecoration(labelText: 'Título')),
              TextField(controller: body, decoration: const InputDecoration(labelText: 'Detalle'), maxLines: 3),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Enviar')),
          ],
        ),
      ),
    );
    if (ok == true) {
      await ref.read(feedbackRepositoryProvider).create(
            campaignId: selected.id,
            title: title.text.trim(),
            body: body.text.trim(),
          );
      ref.invalidate(myFeedbackProvider);
    }
    title.dispose();
    body.dispose();
  }
}
