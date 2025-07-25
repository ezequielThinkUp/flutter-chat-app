import 'package:chat/presentation/base/base_state_notifier.dart';
import 'package:chat/presentation/flows/users/models/state.dart';
import 'package:chat/presentation/flows/users/models/action.dart';
import 'package:chat/domain/entities/user.dart';
import 'package:chat/infrastructure/repositories/auth_repository_impl.dart';

import 'package:chat/data/datasources/auth/auth_remote_datasource.dart';
import 'package:chat/infrastructure/services/auth_service.dart';
import 'package:chat/infrastructure/storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:chat/global/environment.dart';

/// Notifier que maneja el estado y las acciones del flujo de usuarios.
class UsersNotifier extends BaseStateNotifier<UsersState, UsersAction> {
  // Dependencias para logout
  late final AuthRepositoryImpl _authRepository;

  UsersNotifier() : super(const UsersState()) {
    _initializeDependencies();
  }

  /// Inicializa las dependencias internas del notifier.
  void _initializeDependencies() {
    // Crear Dio independiente
    final dio = Dio(BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Crear auth repository usando DataSource abstraction
    final authService = AuthService(dio);
    final authDataSource = AuthRemoteDataSource(authService);
    final secureStorage = SecureStorage();
    _authRepository = AuthRepositoryImpl(authDataSource, secureStorage);
  }

  @override
  void handleAction(UsersAction action) {
    switch (action) {
      case LoadUsers():
        _loadUsers();
        break;
      case RefreshUsers():
        _refreshUsers();
        break;
      case UpdateUserOnlineStatus():
        _updateUserOnlineStatus(action.userId, action.isOnline);
        break;
      case SelectUser():
        _selectUser(action.userId, action.userName);
        break;
      case Logout():
        _logout();
        break;
      case ToggleOnlineStatus():
        _toggleOnlineStatus();
        break;
    }
  }

  /// Carga la lista inicial de usuarios.
  Future<void> _loadUsers() async {
    try {
      updateState((state) => state.copyWith(
            isLoading: true,
            message: null,
          ));

      // Simular carga desde API
      await Future.delayed(const Duration(seconds: 1));

      final users = [
        const User(
            id: '1', name: 'María', email: 'maria@test.com', isOnline: true),
        const User(
            id: '2', name: 'Juan', email: 'juan@test.com', isOnline: false),
        const User(id: '3', name: 'Ana', email: 'ana@test.com', isOnline: true),
        const User(
            id: '4', name: 'Carlos', email: 'carlos@test.com', isOnline: false),
        const User(
            id: '5', name: 'Laura', email: 'laura@test.com', isOnline: true),
      ];

      updateState((state) => state.copyWith(
            users: users,
            isLoading: false,
            message: null,
          ));
    } catch (e) {
      updateState((state) => state.copyWith(
            isLoading: false,
            message: 'Error al cargar usuarios: $e',
          ));
    }
  }

  /// Refresca la lista de usuarios (pull-to-refresh).
  Future<void> _refreshUsers() async {
    try {
      updateState((state) => state.copyWith(isRefreshing: true));

      // Simular refresh
      await Future.delayed(const Duration(milliseconds: 800));

      // Recargar usuarios
      await _loadUsers();

      updateState((state) => state.copyWith(isRefreshing: false));
    } catch (e) {
      updateState((state) => state.copyWith(
            isRefreshing: false,
            message: 'Error al refrescar: $e',
          ));
    }
  }

  /// Actualiza el estado online de un usuario específico.
  void _updateUserOnlineStatus(String userId, bool isOnline) {
    final updatedUsers = state.users.map((user) {
      if (user.id == userId) {
        return user.copyWith(isOnline: isOnline);
      }
      return user;
    }).toList();

    updateState((state) => state.copyWith(users: updatedUsers));
  }

  /// Selecciona un usuario para ir al chat.
  void _selectUser(String userId, String userName) {
    // TODO: Implementar navegación al chat
    // navigateTo('/chat', arguments: {'userId': userId, 'userName': userName});
    print('📱 Seleccionando usuario: $userName ($userId)');
  }

  /// Cierra la sesión del usuario.
  Future<void> _logout() async {
    try {
      updateState((state) => state.copyWith(
            isLoading: true,
            message: 'Cerrando sesión...',
          ));

      print('🚪 Iniciando logout...');

      // Limpiar datos de sesión usando el repositorio real
      await _authRepository.logout();

      // Verificar que la limpieza fue exitosa
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser != null) {
        throw Exception('Error: La sesión no se limpió correctamente');
      }

      updateState((state) => state.copyWith(
            isLoading: false,
            message: 'Sesión cerrada exitosamente',
          ));

      print('✅ Logout completado y verificado');

      // La navegación se manejará desde la UI
    } catch (e) {
      print('❌ Error en logout: $e');

      // Intentar limpieza forzada en caso de error
      try {
        await _authRepository.logout(); // Segundo intento
        print('⚠️ Limpieza forzada ejecutada');
      } catch (forceError) {
        print('❌ Error en limpieza forzada: $forceError');
      }

      updateState((state) => state.copyWith(
            isLoading: false,
            message: 'Error al cerrar sesión: $e',
          ));
    }
  }

  /// Cambia el estado online del usuario actual.
  void _toggleOnlineStatus() {
    final newStatus = !state.isOnline;
    updateState((state) => state.copyWith(isOnline: newStatus));

    // TODO: Notificar al servidor el cambio de estado
    print('🔄 Estado online cambiado a: $newStatus');
  }
}
