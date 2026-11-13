import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/wallet_repository.dart';

final walletProvider = FutureProvider.autoDispose<WalletBalance>((ref) {
  return ref.watch(walletRepositoryProvider).getBalance();
});

final walletTxProvider =
    FutureProvider.autoDispose<List<WalletTransaction>>((ref) {
  return ref.watch(walletRepositoryProvider).transactions();
});

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncWallet = ref.watch(walletProvider);
    final asyncTx = ref.watch(walletTxProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('TestCredits')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          asyncWallet.when(
            data: (wallet) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Saldo disponible', style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '${wallet.availableBalance} TC',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                Text('Reservado: ${wallet.reservedBalance} TC'),
              ],
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
          ),
          const SizedBox(height: 24),
          Text('Historial', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          asyncTx.when(
            data: (txs) {
              if (txs.isEmpty) return const Text('Sin movimientos.');
              return Column(
                children: txs
                    .map(
                      (t) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('${t.entryType} · ${t.amountTc} TC'),
                        subtitle: Text(
                          '${t.creditOrigin ?? '-'} · saldo ${t.balanceAfter}',
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
          ),
          const SizedBox(height: 16),
          Text(
            'Los créditos no son retirables ni convertibles a dinero real. '
            'Compras solo vía Google Play Billing (verificación en backend).',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
