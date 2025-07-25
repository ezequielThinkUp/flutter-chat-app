import 'package:dio/dio.dart';
import 'package:chat/domain/repositories/auth_repository.dart';

/// Interceptor que maneja respuestas 401 (Unauthorized).
///
/// Cuando recibe un 401, limpia la sesión automáticamente.
class UnauthorizedInterceptor extends Interceptor {
  final AuthRepository _authRepository;

  UnauthorizedInterceptor(this._authRepository);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final statusCode = response?.statusCode;
    final path = err.requestOptions.path;

    // Manejar específicamente errores 401
    if (statusCode == 401) {
      print('🚨 Error 401 detectado en: $path');
      await _handleUnauthorized(err.requestOptions);
    }

    // Manejar otros errores de autenticación/autorización
    else if (statusCode == 403) {
      print('🚫 Error 403 (Forbidden) en: $path');
    }

    // Continuar con el manejo normal del error
    handler.next(err);
  }

  /// Maneja la respuesta 401 Unauthorized.
  Future<void> _handleUnauthorized(RequestOptions requestOptions) async {
    final path = requestOptions.path;

    try {
      print('🧹 Limpiando sesión por 401 en: $path');

      // Limpiar toda la sesión de autenticación
      await _authRepository.logout();

      // Log del tipo de error según la ruta
      if (path.contains('refresh')) {
        print('⚠️ Sesión expirada durante renovación de token');
      } else {
        print('⚠️ Token inválido en request: $path');
      }

      print('✅ Sesión limpiada por 401 - usuario debe hacer login nuevamente');
    } catch (e) {
      print('❌ Error manejando 401: $e');
    }
  }
}
