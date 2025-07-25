import 'package:chat/presentation/base/base_action.dart';

/// Acciones disponibles en el flujo de login.
/// 
/// Utiliza sealed class para garantizar que todas las acciones
/// posibles están definidas y el compilador puede verificar
/// que se manejen todas en el switch.
sealed class LoginAction extends BaseAction {
  const LoginAction();
}

/// Acción para actualizar el email.
class UpdateEmail extends LoginAction {
  final String email;
  
  const UpdateEmail(this.email);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdateEmail && other.email == email;
  }

  @override
  int get hashCode => email.hashCode;
}

/// Acción para actualizar la contraseña.
class UpdatePassword extends LoginAction {
  final String password;
  
  const UpdatePassword(this.password);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdatePassword && other.password == password;
  }

  @override
  int get hashCode => password.hashCode;
}

/// Acción para validar el email.
class ValidateEmail extends LoginAction {
  const ValidateEmail();
}

/// Acción para validar la contraseña.
class ValidatePassword extends LoginAction {
  const ValidatePassword();
}

/// Acción para enviar el formulario de login.
class SubmitLogin extends LoginAction {
  const SubmitLogin();
}

/// Acción para limpiar el formulario.
class ClearForm extends LoginAction {
  const ClearForm();
} 