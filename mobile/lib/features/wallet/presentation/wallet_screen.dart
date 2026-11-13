import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../billing/presentation/billing_screen.dart';
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
    final l10n = context.l10n;
    final asyncWallet = ref.watch(walletProvider);
    final asyncTx = ref.watch(walletTxProvider);
    return Scaffold(
      body: AppScaffoldBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(walletProvider);
              ref.invalidate(walletTxProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(l10n.walletTitle, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  l10n.walletSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                asyncWallet.when(
                  data: (wallet) => CreditBalanceCard(
                    available: wallet.availableBalance,
                    reserved: wallet.reservedBalance,
                    onBuy: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const BillingScreen()),
                    ),
                  ),
                  loading: () => const LoadingState(),
                  error: (e, _) => ErrorState(message: '$e'),
                ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(
                  title: l10n.history,
                  subtitle: l10n.historySubtitle,
                ),
                const SizedBox(height: AppSpacing.sm),
                asyncTx.when(
                  data: (txs) {
                    if (txs.isEmpty) {
                      return EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: l10n.noMovements,
                        message: l10n.noMovementsMessage,
                      );
                    }
                    return Column(
                      children: txs.map((t) {
                        final positive = t.amountTc >= 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: AppCard(
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: positive
                                        ? AppColors.successSoft
                                        : AppColors.errorSoft,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    positive
                                        ? Icons.south_west_rounded
                                        : Icons.north_east_rounded,
                                    color: positive
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.entryType,
                                        style: Theme.of(context).textTheme.titleSmall,
                                      ),
                                      Text(
                                        '${t.creditOrigin ?? '—'} · saldo ${t.balanceAfter}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${positive ? '+' : ''}${t.amountTc} TC',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: positive
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const LoadingState(),
                  error: (e, _) => ErrorState(message: '$e'),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.creditsDisclaimer,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
