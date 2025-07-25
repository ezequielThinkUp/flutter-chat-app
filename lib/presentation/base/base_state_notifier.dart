import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/presentation/base/base_action.dart';

/// Notifier base para manejar estado y acciones de flujos.
///
/// Proporciona funcionalidad común para:
/// - Manejo de estado con cualquier tipo de State
/// - Procesamiento de acciones con BaseAction
/// - Navegación y alertas
///
/// Ejemplo de implementación:
/// ```dart
/// class LoginNotifier extends BaseStateNotifier<LoginState, LoginAction> {
///   LoginNotifier() : super(const LoginState());
///
///   @override
///   void handleAction(LoginAction action) {
///     switch (action) {
///       case UpdateEmail(email: final email):
///         state = state.copyWith(email: email);
///         break;
///       // ...
///     }
///   }
/// }
/// ```
abstract class BaseStateNotifier<S, A extends BaseAction>
    extends StateNotifier<S> {
  BaseStateNotifier(S initialState) : super(initialState);

  /// Método principal para manejar acciones.
  /// Debe ser implementado por las clases hijas.
  void handleAction(A action);

  /// Método de conveniencia para ejecutar acciones.
  void execute(A action) {
    handleAction(action);
  }

  /// Actualiza el estado de forma segura.
  void updateState(S Function(S currentState) updater) {
    state = updater(state);
  }

  // Funcionalidades de navegación y alertas
  // Estas serían implementadas en versiones más avanzadas
  void navigateTo(String route) {
    // TODO: Implementar navegación
  }

  void showAlert(String message) {
    // TODO: Implementar alertas
  }
}
