/// Estado del flujo de registro.
///
/// Contiene toda la información necesaria para la pantalla de registro
/// incluyendo los valores de los campos y validaciones.
class RegisterState {
  /// Nombre ingresado por el usuario.
  final String name;

  /// Email ingresado por el usuario.
  final String email;

  /// Contraseña ingresada por el usuario.
  final String password;

  /// Confirmación de contraseña.
  final String confirmPassword;

  /// Indica si se está procesando el registro.
  final bool isLoading;

  /// Indica si el nombre es válido.
  final bool isNameValid;

  /// Indica si el email es válido.
  final bool isEmailValid;

  /// Indica si la contraseña es válida.
  final bool isPasswordValid;

  /// Indica si las contraseñas coinciden.
  final bool passwordsMatch;

  /// Mensaje de error o éxito.
  final String? message;

  const RegisterState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.isNameValid = true,
    this.isEmailValid = true,
    this.isPasswordValid = true,
    this.passwordsMatch = true,
    this.message,
  });

  /// Indica si el formulario es válido para enviar.
  bool get canSubmit =>
      name.isNotEmpty &&
      email.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      isNameValid &&
      isEmailValid &&
      isPasswordValid &&
      passwordsMatch &&
      !isLoading;

  RegisterState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    bool? isLoading,
    bool? isNameValid,
    bool? isEmailValid,
    bool? isPasswordValid,
    bool? passwordsMatch,
    String? message,
  }) {
    return RegisterState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isLoading: isLoading ?? this.isLoading,
      isNameValid: isNameValid ?? this.isNameValid,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      passwordsMatch: passwordsMatch ?? this.passwordsMatch,
      message: message ?? this.message,
    );
  }
}
