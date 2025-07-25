import 'package:chat/domain/entities/user.dart';

/// Estado del flujo de usuarios.
///
/// Maneja la lista de usuarios, estados de conexión y operaciones
/// como pull-to-refresh y logout.
class UsersState {
  /// Lista de usuarios disponibles.
  final List<User> users;

  /// Indica si se está cargando la lista.
  final bool isLoading;

  /// Indica si se está haciendo pull-to-refresh.
  final bool isRefreshing;

  /// Usuario actual (para mostrar en header).
  final User? currentUser;

  /// Estado de conexión del usuario actual.
  final bool isOnline;

  /// Mensaje de error o estado.
  final String? message;

  const UsersState({
    this.users = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.currentUser,
    this.isOnline = false,
    this.message,
  });

  /// Indica si hay usuarios para mostrar.
  bool get hasUsers => users.isNotEmpty;

  /// Usuarios online.
  List<User> get onlineUsers => users.where((u) => u.isOnline).toList();

  /// Usuarios offline.
  List<User> get offlineUsers => users.where((u) => !u.isOnline).toList();

  UsersState copyWith({
    List<User>? users,
    bool? isLoading,
    bool? isRefreshing,
    User? currentUser,
    bool? isOnline,
    String? message,
  }) {
    return UsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      currentUser: currentUser ?? this.currentUser,
      isOnline: isOnline ?? this.isOnline,
      message: message ?? this.message,
    );
  }
}
