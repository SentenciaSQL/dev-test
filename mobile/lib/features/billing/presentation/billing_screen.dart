import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
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
    final l10n = context.l10n;
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
                      tooltip: l10n.back,
                    ),
                    Expanded(
                      child: Text(
                        l10n.buyCreditsTitle,
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
                            l10n.billingDisclaimer,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SectionHeader(
                          title: l10n.packages,
                          subtitle: l10n.packagesSubtitle,
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
                        SectionHeader(
                          title: l10n.subscriptions,
                          subtitle: l10n.subscriptionsSubtitle,
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
    final l10n = context.l10n;
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
                StatusBadge(label: l10n.recommended, tone: BadgeTone.info),
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
            label: l10n.simulatePlayPurchase,
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
                        context.l10n.purchaseVerified(
                          '${result['status']}',
                          result['creditedTc'] ?? 0,
                        ),
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.purchaseFailed('$e'))),
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
