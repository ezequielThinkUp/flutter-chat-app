import 'package:chat/infrastructure/models/auth_response_model.dart';

/// Interface que define las operaciones de datos de autenticación.
///
/// Esta abstracción permite cambiar la fuente de datos (API, local, mock)
/// sin afectar la lógica del repositorio.
abstract class AuthDataSource {
  /// Realiza login con credenciales.
  ///
  /// [credentials] Map con email y password
  /// Returns [AuthResponseModel] con los datos de autenticación
  /// Throws Exception si hay error en el login
  Future<AuthResponseModel> login(Map<String, dynamic> credentials);

  /// Realiza logout del usuario actual.
  ///
  /// Throws Exception si hay error en el logout
  Future<void> logout();

  /// Renueva el token de autenticación.
  ///
  /// [tokenData] Map con refresh_token
  /// Returns [AuthResponseModel] con el nuevo token
  /// Throws Exception si hay error renovando el token
  Future<AuthResponseModel> refreshToken(Map<String, dynamic> tokenData);
}
