import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/presentation/base/base_provider.dart';
import 'package:chat/presentation/flows/login/providers/login_notifier.dart';
import 'package:chat/presentation/flows/login/states/state.dart';
import 'package:chat/presentation/flows/login/states/action.dart';

/// Provider del flujo de login.
///
/// Utiliza BaseProvider para encapsular la creación y configuración
/// del StateNotifierProvider con funcionalidades adicionales.
final loginProvider = BaseProvider<LoginNotifier, LoginState, LoginAction>(
  (ref) => LoginNotifier(),
);

/// Extension methods para facilitar el uso del provider.
extension LoginProviderX on WidgetRef {
  /// Acceso rápido al estado de login.
  LoginState get loginState => watch(loginProvider.provider);

  /// Acceso rápido al notifier de login.
  LoginNotifier get loginNotifier => read(loginProvider.provider.notifier);

  /// Método de conveniencia para ejecutar acciones de login.
  void executeLoginAction(LoginAction action) {
    loginNotifier.handleAction(action);
  }
}
