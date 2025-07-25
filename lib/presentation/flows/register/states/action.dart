import 'package:chat/presentation/base/base_action.dart';

/// Acciones disponibles en el flujo de registro.
sealed class RegisterAction extends BaseAction {
  const RegisterAction();
}

/// Acción para actualizar el nombre.
class UpdateName extends RegisterAction {
  final String name;

  const UpdateName(this.name);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdateName && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}

/// Acción para actualizar el email.
class UpdateEmail extends RegisterAction {
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
class UpdatePassword extends RegisterAction {
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

/// Acción para actualizar la confirmación de contraseña.
class UpdateConfirmPassword extends RegisterAction {
  final String confirmPassword;

  const UpdateConfirmPassword(this.confirmPassword);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdateConfirmPassword &&
        other.confirmPassword == confirmPassword;
  }

  @override
  int get hashCode => confirmPassword.hashCode;
}

/// Acción para enviar el formulario de registro.
class SubmitRegister extends RegisterAction {
  const SubmitRegister();
}

/// Acción para limpiar el formulario.
class ClearForm extends RegisterAction {
  const ClearForm();
}
