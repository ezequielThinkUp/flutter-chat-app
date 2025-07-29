/// Estado del flujo de login.
///
/// Contiene toda la información necesaria para la pantalla de login
/// incluyendo los valores de los campos y el estado de la operación.
class LoginState {
  /// Email ingresado por el usuario.
  final String email;

  /// Contraseña ingresada por el usuario.
  final String password;

  /// Indica si se está procesando el login.
  final bool isLoading;

  /// Indica si el email es válido.
  final bool isEmailValid;

  /// Indica si la contraseña es válida.
  final bool isPasswordValid;

  /// Mensaje de error o éxito.
  final String? message;

  /// Indica si debe redirigir al login por error de conexión.
  final bool shouldRedirectToLogin;

  const LoginState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.isEmailValid = true,
    this.isPasswordValid = true,
    this.message,
    this.shouldRedirectToLogin = false,
  });

  /// Indica si el formulario es válido para enviar.
  bool get canSubmit =>
      email.isNotEmpty &&
      password.isNotEmpty &&
      isEmailValid &&
      isPasswordValid &&
      !isLoading;

  LoginState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    bool? isEmailValid,
    bool? isPasswordValid,
    String? message,
    bool? shouldRedirectToLogin,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      message: message ?? this.message,
      shouldRedirectToLogin:
          shouldRedirectToLogin ?? this.shouldRedirectToLogin,
    );
  }
}
