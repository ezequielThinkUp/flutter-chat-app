import 'package:chat/domain/entities/auth_result.dart';
import 'package:chat/domain/repositories/auth_repository.dart';

/// Caso de uso para el login de usuario.
///
/// Encapsula la lógica de negocio específica del login,
/// incluyendo validaciones y reglas de dominio.
class LoginUseCase {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  /// Ejecuta el login con validaciones de dominio.
  Future<AuthResult> call(LoginParams params) async {
    // Validaciones de dominio
    _validateEmail(params.email);
    _validatePassword(params.password);

    // Normalizar email
    final normalizedEmail = params.email.trim().toLowerCase();

    // Ejecutar login
    final result = await _authRepository.login(
      email: normalizedEmail,
      password: params.password,
    );

    // Validaciones post-login
    if (result.isExpired) {
      throw const AuthDomainException('Token expirado al momento del login');
    }

    return result;
  }

  /// Valida el formato del email.
  void _validateEmail(String email) {
    if (email.trim().isEmpty) {
      throw const AuthDomainException('El email es requerido');
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email.trim())) {
      throw const AuthDomainException('El formato del email es inválido');
    }
  }

  /// Valida la contraseña.
  void _validatePassword(String password) {
    if (password.isEmpty) {
      throw const AuthDomainException('La contraseña es requerida');
    }

    if (password.length < 6) {
      throw const AuthDomainException(
          'La contraseña debe tener al menos 6 caracteres');
    }
  }
}

/// Parámetros del caso de uso de login.
class LoginParams {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginParams &&
        other.email == email &&
        other.password == password;
  }

  @override
  int get hashCode => Object.hash(email, password);

  @override
  String toString() => 'LoginParams(email: $email)';
}

/// Excepción específica del dominio de autenticación.
class AuthDomainException implements Exception {
  final String message;

  const AuthDomainException(this.message);

  @override
  String toString() => message;
}
