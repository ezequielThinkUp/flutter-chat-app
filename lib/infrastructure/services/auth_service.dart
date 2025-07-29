import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:chat/config/networking/dio_provider.dart';
import 'package:chat/infrastructure/models/auth_response_model.dart';

part 'auth_service.g.dart';

/// Servicio HTTP para operaciones de autenticación usando Retrofit.
///
/// Genera automáticamente la implementación de las peticiones HTTP.
@RestApi()
abstract class AuthService {
  factory AuthService(Dio dio, {String baseUrl}) = _AuthService;

  /// Realiza login con credenciales.
  @POST('/api/auth/login')
  Future<AuthResponseModel> login(@Body() Map<String, dynamic> credentials);

  /// Realiza logout.
  @POST('/api/auth/logout')
  Future<void> logout();

  /// Renueva el token de autenticación.
  @POST('/api/auth/renew')
  Future<AuthResponseModel> refreshToken(
      @Body() Map<String, dynamic> tokenData);

  /// Obtiene todos los usuarios.
  @GET('/api/users')
  Future<dynamic> getUsers();

  /// Obtiene usuarios online.
  @GET('/api/users/online')
  Future<dynamic> getOnlineUsers();

  /// Obtiene un usuario por ID.
  @GET('/api/users/{id}')
  Future<dynamic> getUserById(@Path('id') String userId);
}

/// Provider para el servicio de autenticación (sin autenticación para evitar dependencia circular).
final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(dioProvider)),
);

/// Provider para el servicio de autenticación con JWT automático.
final authServiceWithAuthProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(dioWithAuthProvider)),
);

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
