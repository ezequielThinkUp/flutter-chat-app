import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/presentation/base/base_state_notifier.dart';
import 'package:chat/presentation/flows/login/states/state.dart';
import 'package:chat/presentation/flows/login/states/action.dart';
import 'package:chat/global/environment.dart';
import 'package:chat/infrastructure/providers/socket/socket_connection_provider.dart';
import 'package:chat/infrastructure/providers/repositories/auth_repository_provider.dart';

/// Notifier que maneja el estado y las acciones del flujo de login.
///
/// PROVIDER INDEPENDIENTE: Crea sus propias dependencias internamente
/// sin depender de otros providers.
class LoginNotifier extends BaseStateNotifier<LoginState, LoginAction> {
  // Dependencias internas (no providers externos)
  late final Dio _dio;
  late final FlutterSecureStorage _storage;

  // Referencia al provider container para acceder a otros providers
  Ref? _ref;

  LoginNotifier() : super(const LoginState()) {
    _initializeDependencies();
  }

  /// Establece la referencia al provider container.
  void setRef(Ref ref) {
    _ref = ref;
  }

  /// Inicializa las dependencias internas del notifier.
  void _initializeDependencies() {
    // Crear Dio independiente
    _dio = Dio(BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Agregar logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('🌐 Login Request: $obj'),
    ));

    // Crear storage independiente
    _storage = const FlutterSecureStorage();

    print('✅ LoginNotifier: Dependencias inicializadas');
  }

  @override
  void handleAction(LoginAction action) {
    switch (action) {
      case UpdateEmail():
        _updateEmail(action.email);
        break;
      case UpdatePassword():
        _updatePassword(action.password);
        break;
      case ValidateEmail():
        _validateEmail();
        break;
      case ValidatePassword():
        _validatePassword();
        break;
      case SubmitLogin():
        _submitLogin();
        break;
      case ClearForm():
        _clearForm();
        break;
    }
  }

  /// Actualiza el email y valida automáticamente.
  void _updateEmail(String email) {
    updateState((state) => state.copyWith(email: email));
    _validateEmail();
  }

  /// Actualiza la contraseña y valida automáticamente.
  void _updatePassword(String password) {
    updateState((state) => state.copyWith(password: password));
    _validatePassword();
  }

  /// Valida el formato del email.
  void _validateEmail() {
    final email = state.email;
    final isValid = _isValidEmail(email);

    updateState((state) => state.copyWith(isEmailValid: isValid));
  }

  /// Valida la contraseña.
  void _validatePassword() {
    final password = state.password;
    final isValid = password.length >= 6;

    updateState((state) => state.copyWith(isPasswordValid: isValid));
  }

  /// Procesa el login del usuario usando AuthRepository.
  Future<void> _submitLogin() async {
    if (!state.canSubmit) return;

    try {
      updateState((state) => state.copyWith(
            isLoading: true,
            message: null,
          ));

      print('🚀 Iniciando login para: ${state.email}');

      // Usar AuthRepository para login
      if (_ref != null) {
        final authRepository = _ref!.read(authRepositoryProvider);
        final authResult = await authRepository.login(
          email: state.email,
          password: state.password,
        );

        print('✅ Login exitoso: ${authResult.user.name}');
        print('🔑 Token guardado: ${authResult.token.substring(0, 20)}...');

        updateState((state) => state.copyWith(
              isLoading: false,
              message: 'Login exitoso',
            ));

        // Conectar socket después del login exitoso
        try {
          print('🔌 Conectando socket después del login exitoso...');
          print(
              '🔌 Usuario logueado: ${authResult.user.name} (${authResult.user.id})');

          // Verificar que tenemos la referencia
          if (_ref != null) {
            print('✅ Referencia al provider container disponible');

            // Obtener el socket connection provider
            final socketConnectionNotifier =
                _ref!.read(socketConnectionProvider.notifier);
            print('✅ SocketConnectionNotifier obtenido');

            // Llamar al método de conexión
            await socketConnectionNotifier.onLoginSuccess();
            print('✅ Socket conectado exitosamente');
          } else {
            print('❌ No hay referencia al provider container');
          }
        } catch (e) {
          print('❌ Error conectando socket: $e');
          print('❌ Stack trace: ${StackTrace.current}');
        }
      } else {
        throw Exception('No hay referencia al provider container');
      }

      // TODO: Disparar navegación al flujo principal
      // navigateTo('/users');
    } catch (e) {
      print('❌ Error en login: $e');

      String errorMessage = 'Error de conexión';
      bool shouldRedirectToLogin = false;

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.sendTimeout:
            errorMessage =
                'Error de conexión: El servidor no responde. Verifica tu conexión a internet.';
            shouldRedirectToLogin = true;
            break;
          case DioExceptionType.connectionError:
            errorMessage =
                'Error de conexión: No se puede conectar al servidor.';
            shouldRedirectToLogin = true;
            break;
          default:
            if (e.response?.statusCode == 400) {
              errorMessage = 'Credenciales inválidas';
            } else if (e.response?.statusCode == 404) {
              errorMessage = 'Usuario no encontrado';
            } else if (e.response?.statusCode == 500) {
              errorMessage = 'Error del servidor. Intenta más tarde.';
            } else {
              errorMessage = 'Error de conexión: ${e.message}';
            }
        }
      } else if (e.toString().contains('connection timeout')) {
        errorMessage =
            'Error de conexión: El servidor no responde. Verifica tu conexión a internet.';
        shouldRedirectToLogin = true;
      }

      updateState((state) => state.copyWith(
            isLoading: false,
            message: errorMessage,
            shouldRedirectToLogin: shouldRedirectToLogin,
          ));

      // Si es un error de conexión, mostrar mensaje más prominente
      if (shouldRedirectToLogin) {
        print('⚠️ Error de conexión detectado - Redirigiendo al login');
        // Aquí podrías disparar una acción para mostrar un diálogo o snackbar
      }
    }
  }

  /// Limpia el formulario.
  void _clearForm() {
    state = const LoginState();
  }

  /// Valida si el email tiene un formato correcto.
  bool _isValidEmail(String email) {
    if (email.isEmpty) return true;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Limpia recursos al destruir el notifier.
  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }
}
