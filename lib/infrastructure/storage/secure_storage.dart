import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// Servicio de almacenamiento seguro para datos de autenticación.
///
/// Utiliza Flutter Secure Storage para guardar de forma encriptada
/// el token JWT y datos relacionados con la autenticación.
class SecureStorage {
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userDataKey = 'user_data';
  static const _tokenExpiryKey = 'token_expiry';

  final FlutterSecureStorage _storage;

  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Guarda el token JWT de forma segura.
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
      print('🔐 Token guardado en secure storage');
    } catch (e) {
      print('❌ Error guardando token: $e');
      throw Exception('Error guardando token');
    }
  }

  /// Obtiene el token JWT guardado.
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      print('❌ Error obteniendo token: $e');
      return null;
    }
  }

  /// Guarda el refresh token.
  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      print('🔄 Refresh token guardado');
    } catch (e) {
      print('❌ Error guardando refresh token: $e');
    }
  }

  /// Obtiene el refresh token.
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      print('❌ Error obteniendo refresh token: $e');
      return null;
    }
  }

  /// Guarda datos del usuario como JSON.
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final userJson = jsonEncode(userData);
      await _storage.write(key: _userDataKey, value: userJson);
      print('👤 Datos de usuario guardados');
    } catch (e) {
      print('❌ Error guardando datos de usuario: $e');
      throw Exception('Error guardando datos de usuario');
    }
  }

  /// Obtiene los datos del usuario guardados.
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userJson = await _storage.read(key: _userDataKey);
      if (userJson == null) return null;

      return jsonDecode(userJson) as Map<String, dynamic>;
    } catch (e) {
      print('❌ Error obteniendo datos de usuario: $e');
      return null;
    }
  }

  /// Guarda la fecha de expiración del token.
  Future<void> saveTokenExpiry(DateTime expiryDate) async {
    try {
      await _storage.write(
        key: _tokenExpiryKey,
        value: expiryDate.toIso8601String(),
      );
    } catch (e) {
      print('❌ Error guardando fecha de expiración: $e');
    }
  }

  /// Obtiene la fecha de expiración del token.
  Future<DateTime?> getTokenExpiry() async {
    try {
      final expiryString = await _storage.read(key: _tokenExpiryKey);
      if (expiryString == null) return null;

      return DateTime.parse(expiryString);
    } catch (e) {
      print('❌ Error obteniendo fecha de expiración: $e');
      return null;
    }
  }

  /// Verifica si el token guardado es válido (no expirado).
  Future<bool> isTokenValid() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) return false;

      final expiry = await getTokenExpiry();
      if (expiry == null) {
        // Si no hay fecha de expiración, asumir que es válido por ahora
        return true;
      }

      return DateTime.now().isBefore(expiry);
    } catch (e) {
      print('❌ Error verificando validez del token: $e');
      return false;
    }
  }

  /// Limpia todos los datos de autenticación.
  Future<void> clearAuthData() async {
    try {
      await Future.wait([
        _storage.delete(key: _tokenKey),
        _storage.delete(key: _refreshTokenKey),
        _storage.delete(key: _userDataKey),
        _storage.delete(key: _tokenExpiryKey),
      ]);
      print('🧹 Datos de autenticación eliminados');
    } catch (e) {
      print('❌ Error eliminando datos de autenticación: $e');
    }
  }

  /// Verifica si existe una sesión guardada.
  Future<bool> hasStoredSession() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Guarda todos los datos de una sesión completa.
  Future<void> saveSession({
    required String token,
    String? refreshToken,
    Map<String, dynamic>? userData,
    DateTime? expiresAt,
  }) async {
    try {
      // Guardar token principal
      await saveToken(token);

      // Guardar refresh token si se proporciona
      if (refreshToken != null) {
        await saveRefreshToken(refreshToken);
      }

      // Guardar datos de usuario si se proporcionan
      if (userData != null) {
        await saveUserData(userData);
      }

      // Guardar fecha de expiración si se proporciona
      if (expiresAt != null) {
        await saveTokenExpiry(expiresAt);
      }

      print('💾 Sesión completa guardada');
    } catch (e) {
      print('❌ Error guardando sesión: $e');
      throw Exception('Error guardando sesión');
    }
  }

  /// Obtiene todos los datos de la sesión actual.
  Future<SessionData?> getSession() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final refreshToken = await getRefreshToken();
      final userData = await getUserData();
      final expiry = await getTokenExpiry();

      return SessionData(
        token: token,
        refreshToken: refreshToken,
        userData: userData,
        expiresAt: expiry,
      );
    } catch (e) {
      print('❌ Error obteniendo sesión: $e');
      return null;
    }
  }

  /// Método de debug para verificar el token actual
  Future<void> debugToken() async {
    try {
      final token = await getToken();
      if (token != null) {
        print('🔍 DEBUG TOKEN:');
        print('   - Token: ${token.substring(0, 20)}...');
        print('   - Longitud: ${token.length}');
        print('   - Es válido: ${await isTokenValid()}');

        // Verificar si expira pronto
        final expiry = await getTokenExpiry();
        if (expiry != null) {
          print('   - Expira en: $expiry');
          print(
              '   - Expira pronto: ${DateTime.now().add(const Duration(minutes: 5)).isAfter(expiry)}');
        }
      } else {
        print('❌ DEBUG: No hay token guardado');
      }
    } catch (e) {
      print('❌ DEBUG: Error verificando token: $e');
    }
  }
}

/// Datos de una sesión de autenticación.
class SessionData {
  final String token;
  final String? refreshToken;
  final Map<String, dynamic>? userData;
  final DateTime? expiresAt;

  const SessionData({
    required this.token,
    this.refreshToken,
    this.userData,
    this.expiresAt,
  });

  /// Verifica si la sesión ha expirado.
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Verifica si la sesión expira pronto (en los próximos 5 minutos).
  bool get expiresSoon {
    if (expiresAt == null) return false;
    return DateTime.now().add(const Duration(minutes: 5)).isAfter(expiresAt!);
  }

  @override
  String toString() {
    return 'SessionData(hasToken: ${token.isNotEmpty}, hasRefreshToken: ${refreshToken != null}, expiresAt: $expiresAt)';
  }
}
