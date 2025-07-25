import 'package:chat/domain/entities/user.dart';

/// Interface que define las operaciones de datos de usuarios.
///
/// Esta abstracción permite cambiar la fuente de datos (API, local, mock)
/// sin afectar la lógica del repositorio.
abstract class UsersDataSource {
  /// Obtiene la lista de usuarios registrados.
  ///
  /// Returns [List<User>] con todos los usuarios disponibles
  /// Throws Exception si hay error obteniendo los usuarios
  Future<List<User>> getUsers();

  /// Obtiene un usuario específico por ID.
  ///
  /// [userId] ID del usuario a obtener
  /// Returns [User] con los datos del usuario
  /// Throws Exception si el usuario no existe o hay error
  Future<User> getUserById(String userId);

  /// Actualiza el estado online de un usuario.
  ///
  /// [userId] ID del usuario
  /// [isOnline] Estado online a establecer
  /// Throws Exception si hay error actualizando el estado
  Future<void> updateUserOnlineStatus(String userId, bool isOnline);
}
