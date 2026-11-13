import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n_ext.dart';
import '../l10n/locale_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({
    super.key,
    this.compact = false,
  });

  /// Compact chip-style control for Login; expanded cards for Preferences.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    final l10n = context.l10n;

    if (compact) {
      return PopupMenuButton<String>(
        tooltip: l10n.language,
        onSelected: (code) {
          ref.read(localeControllerProvider.notifier).setLocale(Locale(code));
        },
        itemBuilder: (context) => [
          PopupMenuItem(value: 'en', child: Text(l10n.languageEnglish)),
          PopupMenuItem(value: 'es', child: Text(l10n.languageSpanish)),
          PopupMenuItem(value: 'ar', child: Text(l10n.languageArabic)),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                _label(l10n, locale.languageCode),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const Icon(Icons.expand_more_rounded, size: 18),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final code in const ['en', 'es', 'ar'])
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Material(
              color: locale.languageCode == code
                  ? AppColors.primarySoft
                  : const Color(0xFFF7F8FB),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                onTap: () {
                  ref.read(localeControllerProvider.notifier).setLocale(Locale(code));
                },
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      Icon(
                        Icons.translate_rounded,
                        color: locale.languageCode == code
                            ? AppColors.primary
                            : AppColors.inkMuted,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _label(l10n, code),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Icon(
                        locale.languageCode == code
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: locale.languageCode == code
                            ? AppColors.primary
                            : AppColors.inkFaint,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _label(AppLocalizations l10n, String code) {
    return switch (code) {
      'es' => l10n.languageSpanish,
      'ar' => l10n.languageArabic,
      _ => l10n.languageEnglish,
    };
  }
}
