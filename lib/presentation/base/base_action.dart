/// Clase base para todas las acciones de flujos de presentación.
///
/// Las acciones representan eventos o intenciones del usuario
/// que pueden cambiar el estado del flujo.
///
/// Ejemplo de implementación:
/// ```dart
/// sealed class LoginAction extends BaseAction {
///   const LoginAction();
/// }
///
/// class UpdateEmail extends LoginAction {
///   final String email;
///   const UpdateEmail(this.email);
/// }
/// ```
abstract class BaseAction {
  const BaseAction();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseAction && other.runtimeType == runtimeType;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}
