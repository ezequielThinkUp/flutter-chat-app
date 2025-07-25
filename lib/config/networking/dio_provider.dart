import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/global/environment.dart';

/// Provider para la instancia de Dio configurada.
///
/// Configuración básica sin interceptors JWT (para evitar dependencia circular).
/// Los interceptors JWT se pueden agregar posteriormente si es necesario.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  // Configuración base
  dio.options = BaseOptions(
    baseUrl: Environment.apiUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  // Interceptor para logging
  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (obj) => print('🌐 Dio: $obj'),
    ),
  );

  // Interceptor básico para manejo de errores de autenticación
  dio.interceptors.add(AuthErrorInterceptor());

  return dio;
});

/// Interceptor para manejar errores de autenticación.
class AuthErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      final exception = AuthenticationException.fromResponse(err.response!);
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: exception,
          response: err.response,
          type: err.type,
        ),
      );
    }
    return handler.next(err);
  }
}

/// Excepción específica para errores de autenticación.
class AuthenticationException implements Exception {
  final String message;

  AuthenticationException(this.message);

  factory AuthenticationException.fromResponse(Response response) {
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      return AuthenticationException(
        data['mensaje'] ?? data['detail'] ?? 'Error de autenticación',
      );
    }
    return AuthenticationException('Error de autenticación');
  }

  @override
  String toString() => message;
}
