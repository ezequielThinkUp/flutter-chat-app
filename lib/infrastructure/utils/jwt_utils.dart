import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';

/// Utilidades para manejo de JSON Web Tokens (JWT).
///
/// Proporciona funcionalidades para decodificar, validar y extraer
/// información de tokens JWT de forma segura.
class JwtUtils {
  /// Decodifica un token JWT sin verificar la firma.
  ///
  /// **Importante**: Solo usar para extraer información del payload,
  /// la validación de firma debe hacerse en el backend.
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      print('❌ Error decodificando JWT: $e');
      return null;
    }
  }

  /// Verifica si un token JWT ha expirado.
  static bool isTokenExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      print('❌ Error verificando expiración JWT: $e');
      return true; // Asumir expirado si hay error
    }
  }

  /// Obtiene la fecha de expiración de un token JWT.
  static DateTime? getExpirationDate(String token) {
    try {
      return JwtDecoder.getExpirationDate(token);
    } catch (e) {
      print('❌ Error obteniendo fecha de expiración: $e');
      return null;
    }
  }

  /// Extrae el User ID del payload del token.
  ///
  /// Busca en varios campos comunes: 'sub', 'user_id', 'uid', 'id'
  static String? extractUserId(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;

    // Intentar varios campos comunes para el user ID
    return payload['sub']?.toString() ??
        payload['user_id']?.toString() ??
        payload['uid']?.toString() ??
        payload['id']?.toString();
  }

  /// Extrae el email del payload del token.
  static String? extractEmail(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;

    return payload['email']?.toString();
  }

  /// Extrae el nombre del usuario del payload del token.
  static String? extractUserName(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;

    return payload['name']?.toString() ??
        payload['username']?.toString() ??
        payload['nombre']?.toString();
  }

  /// Extrae roles del usuario del payload del token.
  static List<String> extractRoles(String token) {
    final payload = decodeToken(token);
    if (payload == null) return [];

    final roles = payload['roles'];
    if (roles is List) {
      return roles.map((role) => role.toString()).toList();
    }

    final role = payload['role']?.toString();
    return role != null ? [role] : [];
  }

  /// Verifica si el token expira en los próximos minutos especificados.
  static bool expiresInMinutes(String token, int minutes) {
    final expirationDate = getExpirationDate(token);
    if (expirationDate == null) return true;

    final now = DateTime.now();
    final threshold = now.add(Duration(minutes: minutes));

    return expirationDate.isBefore(threshold);
  }

  /// Obtiene información completa del usuario desde el token.
  static UserTokenInfo? extractUserInfo(String token) {
    if (isTokenExpired(token)) {
      print('⚠️ Token expirado al extraer información del usuario');
      return null;
    }

    final userId = extractUserId(token);
    final email = extractEmail(token);
    final name = extractUserName(token);
    final roles = extractRoles(token);
    final expirationDate = getExpirationDate(token);

    if (userId == null) {
      print('⚠️ No se pudo extraer User ID del token');
      return null;
    }

    return UserTokenInfo(
      userId: userId,
      email: email,
      name: name,
      roles: roles,
      expirationDate: expirationDate,
    );
  }

  /// Valida que el token tenga la estructura básica correcta.
  static bool isValidTokenStructure(String token) {
    if (token.isEmpty) return false;

    // Un JWT debe tener 3 partes separadas por puntos
    final parts = token.split('.');
    if (parts.length != 3) return false;

    try {
      // Intentar decodificar el header y payload
      final header = _decodeBase64(parts[0]);
      final payload = _decodeBase64(parts[1]);

      return header.isNotEmpty && payload.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Decodifica una cadena Base64 URL-safe.
  static String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Cadena Base64 inválida');
    }

    return utf8.decode(base64Url.decode(output));
  }

  /// Obtiene el tiempo restante hasta la expiración en segundos.
  static int? getSecondsUntilExpiration(String token) {
    final expirationDate = getExpirationDate(token);
    if (expirationDate == null) return null;

    final now = DateTime.now();
    final difference = expirationDate.difference(now);

    return difference.inSeconds > 0 ? difference.inSeconds : 0;
  }
}

/// Información del usuario extraída del token JWT.
class UserTokenInfo {
  final String userId;
  final String? email;
  final String? name;
  final List<String> roles;
  final DateTime? expirationDate;

  const UserTokenInfo({
    required this.userId,
    this.email,
    this.name,
    this.roles = const [],
    this.expirationDate,
  });

  /// Verifica si el usuario tiene un rol específico.
  bool hasRole(String role) {
    return roles.any((r) => r.toLowerCase() == role.toLowerCase());
  }

  /// Verifica si es administrador.
  bool get isAdmin => hasRole('admin') || hasRole('administrator');

  /// Verifica si el token expira pronto (en los próximos 5 minutos).
  bool get expiresSoon {
    if (expirationDate == null) return true;
    return DateTime.now()
        .add(const Duration(minutes: 5))
        .isAfter(expirationDate!);
  }

  @override
  String toString() {
    return 'UserTokenInfo(userId: $userId, email: $email, name: $name, roles: $roles)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserTokenInfo &&
        other.userId == userId &&
        other.email == email &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(userId, email, name);
}
