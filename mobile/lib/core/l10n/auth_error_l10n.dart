import 'l10n_ext.dart';

/// Stable auth error codes stored in [AuthState.error], localized in the UI.
abstract final class AuthErrorCodes {
  static const invalidCredentials = 'invalid_credentials';
  static const emailTaken = 'email_taken';
  static const badRequest = 'bad_request';
  static const noConnection = 'no_connection';
  static const generic = 'generic';
}

String localizeAuthError(AppLocalizations l10n, String? code) {
  return switch (code) {
    AuthErrorCodes.invalidCredentials => l10n.loginErrorInvalidCredentials,
    AuthErrorCodes.emailTaken => l10n.loginErrorEmailTaken,
    AuthErrorCodes.badRequest => l10n.loginErrorBadRequest,
    AuthErrorCodes.noConnection => l10n.loginErrorNoConnection,
    _ => l10n.loginErrorGeneric,
  };
}
