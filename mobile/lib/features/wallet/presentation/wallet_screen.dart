import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/wallet_repository.dart';

final walletProvider = FutureProvider.autoDispose<WalletBalance>((ref) {
  return ref.watch(walletRepositoryProvider).getBalance();
});

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncWallet = ref.watch(walletProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('TestCredits')),
      body: asyncWallet.when(
        data: (wallet) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Saldo disponible', style: Theme.of(context).textTheme.titleMedium),
              Text(
                '${wallet.availableBalance} TC',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 16),
              Text('Saldo reservado: ${wallet.reservedBalance} TC'),
              const SizedBox(height: 24),
              Text(
                'Los créditos no son retirables ni convertibles a dinero real. '
                'Las compras se procesarán solo con Google Play Billing.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
