import 'package:chat/presentation/base/base_state_notifier.dart';
import 'package:chat/presentation/flows/register/states/state.dart';
import 'package:chat/presentation/flows/register/states/action.dart';

/// Notifier que maneja el estado y las acciones del flujo de registro.
class RegisterNotifier
    extends BaseStateNotifier<RegisterState, RegisterAction> {
  RegisterNotifier() : super(const RegisterState());

  @override
  void handleAction(RegisterAction action) {
    switch (action) {
      case UpdateName():
        _updateName(action.name);
        break;
      case UpdateEmail():
        _updateEmail(action.email);
        break;
      case UpdatePassword():
        _updatePassword(action.password);
        break;
      case UpdateConfirmPassword():
        _updateConfirmPassword(action.confirmPassword);
        break;
      case SubmitRegister():
        _submitRegister();
        break;
      case ClearForm():
        _clearForm();
        break;
    }
  }

  /// Actualiza el nombre y valida.
  void _updateName(String name) {
    final isValid = name.trim().length >= 2;
    updateState((state) => state.copyWith(
          name: name,
          isNameValid: isValid,
        ));
  }

  /// Actualiza el email y valida.
  void _updateEmail(String email) {
    final isValid = _isValidEmail(email);
    updateState((state) => state.copyWith(
          email: email,
          isEmailValid: isValid,
        ));
  }

  /// Actualiza la contraseña y valida.
  void _updatePassword(String password) {
    final isValid = password.length >= 6;
    updateState((state) => state.copyWith(
          password: password,
          isPasswordValid: isValid,
        ));
    _checkPasswordsMatch();
  }

  /// Actualiza la confirmación de contraseña.
  void _updateConfirmPassword(String confirmPassword) {
    updateState((state) => state.copyWith(
          confirmPassword: confirmPassword,
        ));
    _checkPasswordsMatch();
  }

  /// Verifica que las contraseñas coincidan.
  void _checkPasswordsMatch() {
    final match = state.password == state.confirmPassword;
    updateState((state) => state.copyWith(passwordsMatch: match));
  }

  /// Procesa el registro del usuario.
  Future<void> _submitRegister() async {
    if (!state.canSubmit) return;

    try {
      updateState((state) => state.copyWith(
            isLoading: true,
            message: null,
          ));

      // Simular llamada a API
      await Future.delayed(const Duration(seconds: 2));

      // Simular éxito
      updateState((state) => state.copyWith(
            isLoading: false,
            message: 'Registro exitoso',
          ));

      // Aquí se podría disparar navegación a login
      // navigateTo('/login');
    } catch (e) {
      updateState((state) => state.copyWith(
            isLoading: false,
            message: 'Error en el registro: ${e.toString()}',
          ));
    }
  }

  /// Limpia el formulario.
  void _clearForm() {
    state = const RegisterState();
  }

  /// Valida si el email tiene un formato correcto.
  bool _isValidEmail(String email) {
    if (email.isEmpty) return true;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
