import 'package:material_ui/material_ui.dart';
import 'package:apptrial/l10n/app_localizations.dart';

export 'package:apptrial/l10n/app_localizations.dart';

extension AppL10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
