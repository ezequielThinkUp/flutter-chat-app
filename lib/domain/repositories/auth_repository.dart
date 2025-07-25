import 'package:chat/domain/entities/auth_result.dart';
import 'package:chat/domain/entities/user.dart';

/// Repositorio de autenticación - Interface de dominio.
///
/// Define las operaciones relacionadas con autenticación
/// sin conocer detalles de implementación.
abstract class AuthRepository {
  /// Autentica un usuario con email y contraseña.
  Future<AuthResult> login({
    required String email,
    required String password,
  });

  /// Cierra la sesión del usuario actual.
  Future<void> logout();

  /// Renueva el token de autenticación actual.
  Future<AuthResult> refreshToken();

  /// Obtiene el usuario autenticado actual.
  Future<User?> getCurrentUser();

  /// Verifica si hay una sesión activa.
  Future<bool> isLoggedIn();

  /// Obtiene el token JWT actual (en memoria).
  Future<String?> getCurrentToken();

  /// Inicializa la autenticación al arranque de la app.
  Future<void> initializeAuth();
}
