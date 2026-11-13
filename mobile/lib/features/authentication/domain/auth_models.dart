class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.roles,
    this.countryCode,
    this.locale = 'en',
    this.emailVerified = false,
  });

  final String id;
  final String email;
  final String displayName;
  final Set<String> roles;
  final String? countryCode;
  final String locale;
  final bool emailVerified;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      roles: ((json['roles'] as List?) ?? const []).map((e) => e.toString()).toSet(),
      countryCode: json['countryCode'] as String?,
      locale: (json['locale'] as String?) ?? 'en',
      emailVerified: (json['emailVerified'] as bool?) ?? false,
    );
  }

  bool get isDeveloper => roles.contains('DEVELOPER');
  bool get isTester => roles.contains('TESTER');
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final AuthUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: (json['expiresIn'] as num).toInt(),
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
