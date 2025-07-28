import 'package:dio/dio.dart';
import 'package:chat/infrastructure/utils/jwt_utils.dart';
import 'package:chat/infrastructure/storage/secure_storage.dart';

/// Interceptor que maneja operaciones relacionadas con autenticación.
///
/// Verifica la validez del token antes de enviar requests y
/// maneja responses relacionados con autenticación.
class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    print('🚀 AuthInterceptor: INTERCEPTOR EJECUTÁNDOSE para ${options.path}');

    try {
      print('🔍 AuthInterceptor: Procesando request a ${options.path}');

      // Solo verificar token para rutas que no sean de autenticación
      if (_requiresAuth(options.path)) {
        print('🔐 AuthInterceptor: Ruta requiere autenticación');
        final token = await _secureStorage.getToken();

        if (token != null) {
          print(
              '🔐 AuthInterceptor: Token encontrado: ${token.substring(0, 20)}...');

          // Verificar si el token está expirado
          if (JwtUtils.isTokenExpired(token)) {
            print('⚠️ Token expirado, intentando refresh...');

            // Intentar renovar el token
            final refreshSuccess = await _tryRefreshToken();

            if (!refreshSuccess) {
              // Si no se pudo renovar, rechazar el request
              handler.reject(
                DioException(
                  requestOptions: options,
                  error: 'Token expirado y no se pudo renovar',
                  type: DioExceptionType.cancel,
                ),
              );
              return;
            }
          }

          // Verificar si el token expira pronto (en los próximos 5 minutos)
          if (JwtUtils.expiresInMinutes(token, 5)) {
            print('⏰ Token expira pronto, renovando preventivamente...');
            await _tryRefreshToken(); // Intentar sin bloquear el request
          }

          // Obtener el token actualizado después del refresh
          final currentToken = await _secureStorage.getToken();
          if (currentToken != null) {
            // Agregar el token al header x-token (formato esperado por el backend)
            options.headers['x-token'] = currentToken;
            print(
                '🔐 Token agregado al header x-token: ${currentToken.substring(0, 20)}...');
          }
        } else {
          print(
              '❌ AuthInterceptor: No hay token disponible para la ruta: ${options.path}');
        }
      } else {
        print(
            '🔓 AuthInterceptor: Ruta no requiere autenticación: ${options.path}');
      }
    } catch (e) {
      print('❌ Error en AuthInterceptor onRequest: $e');
    }

    print('🔍 AuthInterceptor: Headers finales: ${options.headers}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log exitoso para requests autenticados
    if (_requiresAuth(response.requestOptions.path)) {
      print(
          '✅ Request autenticado exitoso: ${response.statusCode} ${response.requestOptions.path}');
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final path = err.requestOptions.path;
    final statusCode = err.response?.statusCode;

    print('❌ Error en request autenticado: $statusCode $path');

    // Manejar errores específicos de autenticación
    if (statusCode == 401) {
      print('🔐 Error 401: Token inválido o expirado');
    } else if (statusCode == 403) {
      print('🚫 Error 403: Sin permisos suficientes');
    }

    handler.next(err);
  }

  /// Verifica si una ruta requiere autenticación.
  bool _requiresAuth(String path) {
    // Rutas que NO requieren autenticación
    final publicPaths = [
      '/login',
      '/register',
      '/forgot-password',
      '/health',
    ];

    return !publicPaths.any((publicPath) => path.contains(publicPath));
  }

  /// Intenta renovar el token usando refresh token.
  Future<bool> _tryRefreshToken() async {
    try {
      // Por ahora, simplemente retornar false ya que no tenemos refresh token implementado
      print('⚠️ Refresh token no implementado aún');
      return false;
    } catch (e) {
      print('❌ Error renovando token: $e');
      return false;
    }
  }
}
