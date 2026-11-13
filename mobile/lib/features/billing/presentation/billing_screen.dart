import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
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
      body: AppScaffoldBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Text(
                        'Comprar créditos',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: asyncProducts.when(
                  data: (products) {
                    final credits = products
                        .where((p) => p.productType == 'CONSUMABLE_CREDITS')
                        .toList();
                    final subs = products
                        .where((p) => p.productType == 'SUBSCRIPTION')
                        .toList();
                    return ListView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      children: [
                        AppCard(
                          accent: true,
                          child: Text(
                            'Pagos digitales solo con Google Play Billing. '
                            'El backend verifica el token antes de acreditar TC.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const SectionHeader(
                          title: 'Paquetes',
                          subtitle: 'Ideal para campañas puntuales',
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ...credits.asMap().entries.map((entry) {
                          final recommended = entry.key == 1;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: _ProductCard(
                              product: entry.value,
                              recommended: recommended,
                            ),
                          );
                        }),
                        const SizedBox(height: AppSpacing.md),
                        const SectionHeader(
                          title: 'Suscripciones',
                          subtitle: 'Planes Free → Studio vía Play',
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ...subs.map(
                          (p) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: _ProductCard(product: p),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const LoadingState(),
                  error: (e, _) => ErrorState(
                    message: '$e',
                    onRetry: () => ref.invalidate(billingProductsProvider),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.product, this.recommended = false});

  final BillingProduct product;
  final bool recommended;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final price = product.priceUsdCents == null
        ? '—'
        : '\$${(product.priceUsdCents! / 100).toStringAsFixed(2)}';
    return AppCard(
      accent: recommended,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(product.title, style: Theme.of(context).textTheme.titleMedium),
              ),
              if (recommended)
                const StatusBadge(label: 'Recomendado', tone: BadgeTone.info),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            product.creditsTc != null ? '${product.creditsTc} TC' : product.sku,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                ),
          ),
          Text(price, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: 'Simular compra Play',
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
          ),
        ],
      ),
    );
  }
}
