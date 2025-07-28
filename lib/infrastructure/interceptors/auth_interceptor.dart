import 'package:dio/dio.dart';
import 'package:chat/infrastructure/utils/jwt_utils.dart';
import 'package:chat/domain/repositories/auth_repository.dart';

/// Interceptor que maneja operaciones relacionadas con autenticación.
///
/// Verifica la validez del token antes de enviar requests y
/// maneja responses relacionados con autenticación.
class AuthInterceptor extends Interceptor {
  final AuthRepository _authRepository;

  AuthInterceptor(this._authRepository);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Solo verificar token para rutas que no sean de autenticación
      if (_requiresAuth(options.path)) {
        final token = await _authRepository.getCurrentToken();

        if (token != null) {
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
            _tryRefreshToken(); // Intentar sin bloquear el request
          }

          // Obtener el token actualizado después del refresh
          final currentToken = await _authRepository.getCurrentToken();
          if (currentToken != null) {
            // Agregar el token al header Authorization
            options.headers['Authorization'] = 'Bearer $currentToken';
            print(
                '🔐 Token agregado al header: ${currentToken.substring(0, 20)}...');
          }
        }
      }
    } catch (e) {
      print('❌ Error en AuthInterceptor onRequest: $e');
    }

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
      // Intentar renovar el token
      await _authRepository.refreshToken();
      print('✅ Token renovado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error renovando token: $e');

      // Si falla la renovación, limpiar la sesión
      try {
        await _authRepository.logout();
        print('🧹 Sesión limpiada tras fallo de renovación');
      } catch (logoutError) {
        print('❌ Error limpiando sesión: $logoutError');
      }

      return false;
    }
  }
}
