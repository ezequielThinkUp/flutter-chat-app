import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/presentation/base/base_provider.dart';
import 'package:chat/presentation/flows/register/providers/register_notifier.dart';
import 'package:chat/presentation/flows/register/states/state.dart';
import 'package:chat/presentation/flows/register/states/action.dart';

/// Provider del flujo de registro.
final registerProvider =
    BaseProvider<RegisterNotifier, RegisterState, RegisterAction>(
  (ref) => RegisterNotifier(),
);

/// Extension methods para facilitar el uso del provider.
extension RegisterProviderX on WidgetRef {
  /// Acceso rápido al estado de registro.
  RegisterState get registerState => watch(registerProvider.provider);

  /// Acceso rápido al notifier de registro.
  RegisterNotifier get registerNotifier =>
      read(registerProvider.provider.notifier);

  /// Método de conveniencia para ejecutar acciones de registro.
  void executeRegisterAction(RegisterAction action) {
    registerNotifier.execute(action);
  }
}
