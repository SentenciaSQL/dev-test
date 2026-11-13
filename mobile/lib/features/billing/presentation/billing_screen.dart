import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../wallet/presentation/wallet_screen.dart';
import '../data/billing_repository.dart';

final billingProductsProvider =
    FutureProvider.autoDispose<List<BillingProduct>>((ref) {
  return ref.watch(billingRepositoryProvider).products();
});

class BillingScreen extends ConsumerWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProducts = ref.watch(billingProductsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Comprar créditos')),
      body: asyncProducts.when(
        data: (products) {
          final credits = products
              .where((p) => p.productType == 'CONSUMABLE_CREDITS')
              .toList();
          final subs = products
              .where((p) => p.productType == 'SUBSCRIPTION')
              .toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Los pagos digitales se procesan solo con Google Play Billing. '
                'El backend verifica el token antes de acreditar TestCredits.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text('Paquetes', style: Theme.of(context).textTheme.titleMedium),
              ...credits.map((p) => _ProductTile(product: p)),
              const SizedBox(height: 16),
              Text('Suscripciones', style: Theme.of(context).textTheme.titleMedium),
              ...subs.map((p) => _ProductTile(product: p)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

class _ProductTile extends ConsumerWidget {
  const _ProductTile({required this.product});

  final BillingProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final price = product.priceUsdCents == null
        ? '—'
        : '\$${(product.priceUsdCents! / 100).toStringAsFixed(2)}';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(product.title),
      subtitle: Text(
        '${product.sku} · $price'
        '${product.creditsTc != null ? ' · ${product.creditsTc} TC' : ''}',
      ),
      trailing: FilledButton.tonal(
        onPressed: () async {
          try {
            final result = await ref
                .read(billingRepositoryProvider)
                .verifyMockPurchase(product);
            ref.invalidate(walletProvider);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Verificado (${result['status']}): '
                    '+${result['creditedTc'] ?? 0} TC',
                  ),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Compra falló: $e')),
              );
            }
          }
        },
        child: const Text('Simular compra'),
      ),
    );
  }
}
