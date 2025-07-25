import 'package:chat/domain/datasources/users_datasource.dart';
import 'package:chat/domain/entities/user.dart';

/// Implementación remota del DataSource de usuarios.
///
/// Por ahora es una implementación mock hasta que se cree el servicio real.
/// En el futuro se comunicará con la API a través de un UsersService.
class UsersRemoteDataSource implements UsersDataSource {
  // TODO: Inyectar UsersService cuando esté disponible
  // final UsersService _usersService;

  const UsersRemoteDataSource();

  @override
  Future<List<User>> getUsers() async {
    try {
      print('🌐 UsersRemoteDataSource: Obteniendo usuarios...');

      // TODO: Reemplazar con llamada real a la API
      // final response = await _usersService.getUsers();
      // return response.map((userModel) => userModel.toDomain()).toList();

      // Mock data por ahora
      await Future.delayed(const Duration(milliseconds: 500));

      final mockUsers = [
        User(
          id: '1',
          name: 'Juan Pérez',
          email: 'juan@ejemplo.com',
          isOnline: true,
        ),
        User(
          id: '2',
          name: 'María García',
          email: 'maria@ejemplo.com',
          isOnline: false,
        ),
        User(
          id: '3',
          name: 'Carlos López',
          email: 'carlos@ejemplo.com',
          isOnline: true,
        ),
      ];

      print('✅ UsersRemoteDataSource: ${mockUsers.length} usuarios obtenidos');
      return mockUsers;
    } catch (e) {
      print('❌ UsersRemoteDataSource: Error obteniendo usuarios: $e');
      throw Exception('Error obteniendo usuarios: $e');
    }
  }

  @override
  Future<User> getUserById(String userId) async {
    try {
      print('🌐 UsersRemoteDataSource: Obteniendo usuario $userId...');

      // TODO: Reemplazar con llamada real a la API
      // final response = await _usersService.getUserById(userId);
      // return response.toDomain();

      // Mock data por ahora
      await Future.delayed(const Duration(milliseconds: 300));

      final mockUser = User(
        id: userId,
        name: 'Usuario Mock',
        email: 'mock@ejemplo.com',
        isOnline: true,
      );

      print('✅ UsersRemoteDataSource: Usuario $userId obtenido');
      return mockUser;
    } catch (e) {
      print('❌ UsersRemoteDataSource: Error obteniendo usuario $userId: $e');
      throw Exception('Error obteniendo usuario: $e');
    }
  }

  @override
  Future<void> updateUserOnlineStatus(String userId, bool isOnline) async {
    try {
      print(
          '🌐 UsersRemoteDataSource: Actualizando estado online de $userId a $isOnline...');

      // TODO: Reemplazar con llamada real a la API
      // await _usersService.updateOnlineStatus(userId, {'isOnline': isOnline});

      // Mock delay por ahora
      await Future.delayed(const Duration(milliseconds: 200));

      print('✅ UsersRemoteDataSource: Estado online de $userId actualizado');
    } catch (e) {
      print(
          '❌ UsersRemoteDataSource: Error actualizando estado de $userId: $e');
      throw Exception('Error actualizando estado online: $e');
    }
  }
}
