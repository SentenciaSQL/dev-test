import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'apptrial_locale_code';

/// Supported app languages. Default is English and is NOT derived from device.
const supportedAppLocales = <Locale>[
  Locale('en'),
  Locale('es'),
  Locale('ar'),
];

class LocaleController extends StateNotifier<Locale> {
  LocaleController() : super(const Locale('en')) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code == null || code.isEmpty) {
      state = const Locale('en');
      return;
    }
    Locale? match;
    for (final locale in supportedAppLocales) {
      if (locale.languageCode == code) {
        match = locale;
        break;
      }
    }
    state = match ?? const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedAppLocales.any((l) => l.languageCode == locale.languageCode)) {
      return;
    }
    state = Locale(locale.languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController();
});
