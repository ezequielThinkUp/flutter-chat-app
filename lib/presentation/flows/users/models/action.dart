import 'package:chat/presentation/base/base_action.dart';

/// Acciones disponibles en el flujo de usuarios.
sealed class UsersAction extends BaseAction {
  const UsersAction();
}

/// Acción para cargar la lista inicial de usuarios.
class LoadUsers extends UsersAction {
  const LoadUsers();
}

/// Acción para refrescar la lista de usuarios (pull-to-refresh).
class RefreshUsers extends UsersAction {
  const RefreshUsers();
}

/// Acción para actualizar el estado online de un usuario.
class UpdateUserOnlineStatus extends UsersAction {
  final String userId;
  final bool isOnline;

  const UpdateUserOnlineStatus({
    required this.userId,
    required this.isOnline,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdateUserOnlineStatus &&
        other.userId == userId &&
        other.isOnline == isOnline;
  }

  @override
  int get hashCode => Object.hash(userId, isOnline);
}

/// Acción para seleccionar un usuario y navegar al chat.
class SelectUser extends UsersAction {
  final String userId;
  final String userName;

  const SelectUser({
    required this.userId,
    required this.userName,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SelectUser &&
        other.userId == userId &&
        other.userName == userName;
  }

  @override
  int get hashCode => Object.hash(userId, userName);
}

/// Acción para cerrar sesión.
class Logout extends UsersAction {
  const Logout();
}

/// Acción para cambiar el estado online del usuario actual.
class ToggleOnlineStatus extends UsersAction {
  const ToggleOnlineStatus();
}
