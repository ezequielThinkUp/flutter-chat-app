import 'package:dio/dio.dart';
import 'package:chat/domain/repositories/auth_repository.dart';

/// Interceptor que agrega automáticamente el token JWT a los headers de las peticiones.
///
/// Se ejecuta antes de cada request y añade el header Authorization
/// con el token actual si está disponible.
class HeaderInterceptor extends Interceptor {
  final AuthRepository _authRepository;

  HeaderInterceptor(this._authRepository);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Obtener el token actual del repositorio
      final token = await _getCurrentToken();

      if (token != null && token.isNotEmpty) {
        // Agregar header de Authorization
        options.headers['Authorization'] = 'Bearer $token';

        print(
            '🔐 Token agregado al header para: ${options.method} ${options.path}');
      } else {
        print(
            '⚠️ No hay token disponible para: ${options.method} ${options.path}');
      }

      // Agregar headers adicionales comunes
      options.headers['Content-Type'] = 'application/json';
      options.headers['Accept'] = 'application/json';
    } catch (e) {
      print('❌ Error agregando headers: $e');
    }

    // Continuar con el request
    handler.next(options);
  }

  /// Obtiene el token actual de forma segura.
  Future<String?> _getCurrentToken() async {
    try {
      return await _authRepository.getCurrentToken();
    } catch (e) {
      print('❌ Error obteniendo token actual: $e');
      return null;
    }
  }
}
