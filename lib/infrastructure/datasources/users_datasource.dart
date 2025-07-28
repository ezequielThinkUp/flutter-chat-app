import 'package:chat/domain/entities/user.dart';

abstract class UsersDataSource {
  /// Obtiene todos los usuarios.
  Future<List<User>> getUsers();

  /// Obtiene solo los usuarios que están online.
  Future<List<User>> getOnlineUsers();

  /// Obtiene un usuario por su ID.
  Future<User> getUserById(String userId);

  /// Actualiza el estado online de un usuario.
  ///
  /// Nota: En la implementación actual, esto se maneja automáticamente
  /// via Socket.IO, por lo que esta función puede no hacer nada.
  Future<void> updateUserOnlineStatus(String userId, bool isOnline);
}
