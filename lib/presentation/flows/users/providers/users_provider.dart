import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/presentation/base/base_provider.dart';
import 'package:chat/presentation/flows/users/providers/users_notifier.dart';
import 'package:chat/presentation/flows/users/models/state.dart';
import 'package:chat/presentation/flows/users/models/action.dart';

/// Provider del flujo de usuarios.
final usersProvider = BaseProvider<UsersNotifier, UsersState, UsersAction>(
  (ref) => UsersNotifier(),
);

/// Extension methods para facilitar el uso del provider.
extension UsersProviderX on WidgetRef {
  /// Acceso rápido al estado de usuarios.
  UsersState get usersState => watch(usersProvider.provider);

  /// Acceso rápido al notifier de usuarios.
  UsersNotifier get usersNotifier => read(usersProvider.provider.notifier);

  /// Método de conveniencia para ejecutar acciones de usuarios.
  void executeUsersAction(UsersAction action) {
    usersNotifier.execute(action);
  }
}
