import 'package:chat/infrastructure/datasources/users_datasource.dart';
import 'package:chat/domain/entities/user.dart';
import 'package:chat/infrastructure/services/auth_service.dart';
import 'package:dio/dio.dart';

class UsersRemoteDataSource implements UsersDataSource {
  final AuthService _authService;

  const UsersRemoteDataSource(this._authService);

  @override
  Future<List<User>> getUsers() async {
    try {
      print('🌐 UsersRemoteDataSource: Obteniendo usuarios de la API...');

      final response = await _authService.getUsers();

      if (response['ok'] == true) {
        final usersData = response['users'] as List;
        final users = usersData
            .map((userData) => User(
                  id: userData['_id'] ?? '',
                  name: userData['name'] ?? '',
                  email: userData['email'] ?? '',
                  isOnline: userData['online'] ?? false,
                ))
            .toList();

        print('✅ UsersRemoteDataSource: ${users.length} usuarios obtenidos');
        return users;
      } else {
        throw Exception('Error en respuesta de API: ${response['message']}');
      }
    } on DioException catch (e) {
      print('❌ UsersRemoteDataSource: Error Dio: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Token expirado o inválido');
      }
      throw Exception('Error de conectividad: ${e.message}');
    } catch (e) {
      print('❌ UsersRemoteDataSource: Error general: $e');
      throw Exception('Error obteniendo usuarios: $e');
    }
  }

  @override
  Future<List<User>> getOnlineUsers() async {
    try {
      print(
          '🌐 UsersRemoteDataSource: Obteniendo usuarios online de la API...');

      final response = await _authService.getOnlineUsers();

      if (response['ok'] == true) {
        final usersData = response['users'] as List;
        final users = usersData
            .map((userData) => User(
                  id: userData['_id'] ?? '',
                  name: userData['name'] ?? '',
                  email: userData['email'] ?? '',
                  isOnline: userData['online'] ?? false,
                ))
            .toList();

        print(
            '✅ UsersRemoteDataSource: ${users.length} usuarios online obtenidos');
        return users;
      } else {
        throw Exception(
            'Error en respuesta de API: ${response.data['message']}');
      }
    } on DioException catch (e) {
      print('❌ UsersRemoteDataSource: Error Dio: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Token expirado o inválido');
      }
      throw Exception('Error de conectividad: ${e.message}');
    } catch (e) {
      print('❌ UsersRemoteDataSource: Error general: $e');
      throw Exception('Error obteniendo usuarios online: $e');
    }
  }

  @override
  Future<User> getUserById(String userId) async {
    try {
      print(
          '🌐 UsersRemoteDataSource: Obteniendo usuario $userId de la API...');

      final response = await _authService.getUserById(userId);

      if (response['ok'] == true) {
        final userData = response['user'];
        final user = User(
          id: userData['_id'] ?? '',
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          isOnline: userData['online'] ?? false,
        );

        print('✅ UsersRemoteDataSource: Usuario ${user.name} obtenido');
        return user;
      } else {
        throw Exception('Error en respuesta de API: ${response['message']}');
      }
    } on DioException catch (e) {
      print('❌ UsersRemoteDataSource: Error Dio: ${e.message}');
      if (e.response?.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      }
      if (e.response?.statusCode == 401) {
        throw Exception('Token expirado o inválido');
      }
      throw Exception('Error de conectividad: ${e.message}');
    } catch (e) {
      print('❌ UsersRemoteDataSource: Error general: $e');
      throw Exception('Error obteniendo usuario: $e');
    }
  }

  @override
  Future<void> updateUserOnlineStatus(String userId, bool isOnline) async {
    // Esta funcionalidad se maneja automáticamente por Socket.IO
    // No necesitamos implementarla aquí ya que el backend actualiza
    // el estado online/offline automáticamente cuando los usuarios
    // se conectan/desconectan via socket
    print('ℹ️ Estado online se actualiza automáticamente via Socket.IO');
  }
}
