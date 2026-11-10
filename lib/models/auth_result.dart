import 'app_user.dart';

class AuthResult {
  const AuthResult({
    required this.result,
    this.user,
    this.challengeId,
    this.emailMasked,
    this.resendAfterSeconds = 0,
  });

  final String result;
  final AppUser? user;
  final String? challengeId;
  final String? emailMasked;
  final int resendAfterSeconds;

  bool get authenticated => result == 'authenticated' && user != null;

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    if (result is! String) {
      throw const FormatException('Respuesta de ingreso no válida.');
    }
    final rawUser = json['user'];
    if (rawUser != null && rawUser is! Map<String, dynamic>) {
      throw const FormatException('Perfil de ingreso no válido.');
    }
    final seconds = json['resend_after_seconds'];
    return AuthResult(
      result: result,
      user: rawUser is Map<String, dynamic> ? AppUser.fromJson(rawUser) : null,
      challengeId: json['challenge_id'] as String?,
      emailMasked: json['email_hint'] as String?,
      resendAfterSeconds: seconds is num
          ? seconds.toInt().clamp(0, 86400).toInt()
          : 60,
    );
  }
}
