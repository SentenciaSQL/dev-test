import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../campaigns/data/campaigns_repository.dart';
import '../data/feedback_repository.dart';

final myFeedbackProvider = FutureProvider.autoDispose<List<FeedbackItem>>((ref) {
  return ref.watch(feedbackRepositoryProvider).mine();
});

class FeedbackScreen extends ConsumerWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final asyncFeedback = ref.watch(myFeedbackProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.feedbackTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context, ref),
        icon: const Icon(Icons.add_comment_outlined),
        label: Text(l10n.newFeedback),
      ),
      body: asyncFeedback.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.noFeedbackYet));
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
        error: (e, _) => Center(child: Text(l10n.errorWithDetails('$e'))),
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
        SnackBar(content: Text(context.l10n.noCampaignsAvailable)),
      );
      return;
    }
    var selected = all.first;
    final title = TextEditingController(text: 'Sample feedback');
    final body = TextEditingController(text: 'Feedback detail from AppTrial');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = context.l10n;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(l10n.newFeedback),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField(
                  initialValue: selected,
                  items: all
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                      .toList(),
                  onChanged: (v) => setState(() => selected = v ?? selected),
                  decoration: InputDecoration(labelText: l10n.navCampaigns),
                ),
                TextField(
                  controller: title,
                  decoration: InputDecoration(labelText: l10n.name),
                ),
                TextField(
                  controller: body,
                  decoration: InputDecoration(labelText: l10n.description),
                  maxLines: 3,
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
                child: Text(l10n.submit),
              ),
            ],
          ),
        );
      },
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
