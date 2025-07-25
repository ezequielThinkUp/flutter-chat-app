import 'package:chat/domain/datasources/auth_datasource.dart';
import 'package:chat/infrastructure/models/auth_response_model.dart';
import 'package:chat/infrastructure/services/auth_service.dart';

/// Implementación remota del DataSource de autenticación.
///
/// Se comunica con la API a través del AuthService.
/// Maneja la conversión de errores y excepciones.
class AuthRemoteDataSource implements AuthDataSource {
  final AuthService _authService;

  const AuthRemoteDataSource(this._authService);

  @override
  Future<AuthResponseModel> login(Map<String, dynamic> credentials) async {
    try {
      print('🌐 AuthRemoteDataSource: Iniciando login...');

      final response = await _authService.login(credentials);

      print('✅ AuthRemoteDataSource: Login exitoso');
      return response;
    } on AuthenticationException catch (e) {
      print('❌ AuthRemoteDataSource: Error de autenticación: ${e.message}');
      throw Exception('Error de autenticación: ${e.message}');
    } catch (e) {
      print('❌ AuthRemoteDataSource: Error inesperado: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      print('🌐 AuthRemoteDataSource: Iniciando logout...');

      await _authService.logout();

      print('✅ AuthRemoteDataSource: Logout exitoso');
    } catch (e) {
      print('❌ AuthRemoteDataSource: Error en logout: $e');
      // El logout local debe continuar aunque falle el remoto
      throw Exception('Error en logout remoto: $e');
    }
  }

  @override
  Future<AuthResponseModel> refreshToken(Map<String, dynamic> tokenData) async {
    try {
      print('🌐 AuthRemoteDataSource: Renovando token...');

      final response = await _authService.refreshToken(tokenData);

      print('✅ AuthRemoteDataSource: Token renovado exitosamente');
      return response;
    } on AuthenticationException catch (e) {
      print('❌ AuthRemoteDataSource: Error renovando token: ${e.message}');
      throw Exception('Error renovando token: ${e.message}');
    } catch (e) {
      print('❌ AuthRemoteDataSource: Error inesperado renovando token: $e');
      throw Exception('Error de conexión renovando token: $e');
    }
  }
}
