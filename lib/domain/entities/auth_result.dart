import 'package:chat/domain/entities/user.dart';

/// Entidad que representa el resultado de una autenticación exitosa.
///
/// Contiene la información pura del dominio sin dependencias externas.
class AuthResult {
  final User user;
  final String token;
  final DateTime expiresAt;

  const AuthResult({
    required this.user,
    required this.token,
    required this.expiresAt,
  });

  /// Indica si el token ha expirado.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Indica si el token expira pronto (dentro de 5 minutos).
  bool get expiressoon =>
      DateTime.now().add(const Duration(minutes: 5)).isAfter(expiresAt);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthResult &&
        other.user == user &&
        other.token == token &&
        other.expiresAt == expiresAt;
  }

  @override
  int get hashCode => Object.hash(user, token, expiresAt);

  @override
  String toString() =>
      'AuthResult(user: $user, token: *****, expiresAt: $expiresAt)';
}
