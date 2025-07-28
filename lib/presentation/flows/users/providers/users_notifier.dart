import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/presentation/base/base_state_notifier.dart';
import 'package:chat/presentation/flows/users/models/state.dart';
import 'package:chat/presentation/flows/users/models/action.dart';
import 'package:chat/domain/repositories/auth_repository.dart';

import 'package:chat/infrastructure/providers/repositories/auth_repository_provider.dart';
import 'package:chat/infrastructure/providers/socket/socket_connection_provider.dart';
import 'package:chat/infrastructure/providers/datasources/users_datasource_provider.dart';
import 'package:chat/infrastructure/datasources/users_datasource.dart';
import 'package:chat/infrastructure/storage/secure_storage.dart';

/// Notifier que maneja el estado y las acciones del flujo de usuarios.
///
/// PROVIDER INDEPENDIENTE: Crea sus propias dependencias internamente
/// sin depender de otros providers para operaciones críticas.
class UsersNotifier extends BaseStateNotifier<UsersState, UsersAction> {
  // Dependencias inyectadas
  final Ref _ref;
  late AuthRepository _authRepository;
  late UsersDataSource _usersDataSource;

  UsersNotifier(this._ref) : super(const UsersState()) {
    _initializeDependencies();
    _loadInitialData();
  }

  /// Inicializa las dependencias del notifier.
  void _initializeDependencies() {
    _authRepository = _ref.read(authRepositoryProvider);
    _usersDataSource = _ref.watch(usersDataSourceProvider);
    print('✅ UsersNotifier: Dependencias inicializadas');
  }

  /// Carga los datos iniciales y conecta el socket automáticamente.
  Future<void> _loadInitialData() async {
    try {
      print('📊 UsersNotifier: Cargando datos iniciales...');

      // Verificar si hay usuario autenticado
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser != null) {
        print('👤 Usuario autenticado encontrado: ${currentUser.name}');

        // Conectar socket automáticamente
        _connectSocketAutomatically();

        // Cargar lista de usuarios
        await _loadUsers();
      } else {
        print('⚠️ No hay usuario autenticado');
      }
    } catch (e) {
      print('❌ Error cargando datos iniciales: $e');
    }
  }

  /// Conecta el socket automáticamente si hay usuario autenticado.
  void _connectSocketAutomatically() {
    try {
      print('🔌 UsersNotifier: Iniciando conexión automática de socket...');

      // Usar el provider de conexión automática
      Future.microtask(() {
        _ref.read(socketConnectionProvider.notifier).onLoginSuccess();
      });
    } catch (e) {
      print('❌ Error conectando socket automáticamente: $e');
    }
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
      case Logout():
        _logout();
        break;
      case SelectUser():
        _selectUser(action.userId, action.userName);
        break;
      case UpdateUserOnlineStatus():
        _updateUserOnlineStatus(action.userId, action.isOnline);
        break;
      case ToggleOnlineStatus():
        _toggleOnlineStatus();
        break;
    }
  }

  /// Carga la lista de usuarios reales de la API.
  Future<void> _loadUsers() async {
    try {
      print('👥 UsersNotifier: Cargando usuarios desde API...');

      // Verificar token antes de hacer la petición
      final token = await _authRepository.getCurrentToken();
      if (token != null) {
        print('🔐 Token disponible: ${token.substring(0, 20)}...');
      } else {
        print('❌ No hay token disponible');
        state = state.copyWith(
          isLoading: false,
          message: 'No hay token de autenticación disponible',
        );
        return;
      }

      // Verificar token directamente desde SecureStorage
      final secureStorage = SecureStorage();
      final directToken = await secureStorage.getToken();
      print(
          '🔐 Token directo desde SecureStorage: ${directToken?.substring(0, 20) ?? 'null'}...');

      state = state.copyWith(isLoading: true);

      // Obtener usuarios reales de la API
      final users = await _usersDataSource.getUsers();

      state = state.copyWith(
        isLoading: false,
        users: users,
        message: 'Usuarios cargados exitosamente',
      );

      print('✅ UsersNotifier: ${users.length} usuarios reales cargados');
    } catch (e) {
      print('❌ UsersNotifier: Error cargando usuarios: $e');
      state = state.copyWith(
        isLoading: false,
        message: 'Error cargando usuarios: $e',
      );
    }
  }

  /// Actualiza la lista de usuarios.
  Future<void> _refreshUsers() async {
    try {
      print('🔄 UsersNotifier: Actualizando usuarios...');
      await _loadUsers();
    } catch (e) {
      print('❌ UsersNotifier: Error refrescando usuarios: $e');
    }
  }

  /// Selecciona un usuario.
  void _selectUser(String userId, String userName) {
    print('👤 UsersNotifier: Usuario seleccionado: $userName ($userId)');
    // TODO: Implementar navegación al chat si es necesario
  }

  /// Actualiza el estado online de un usuario específico.
  void _updateUserOnlineStatus(String userId, bool isOnline) {
    final updatedUsers = state.users.map((user) {
      if (user.id == userId) {
        return user.copyWith(isOnline: isOnline);
      }
      return user;
    }).toList();

    state = state.copyWith(users: updatedUsers);
    print('🔄 Estado online actualizado para usuario $userId: $isOnline');
  }

  /// Cambia el estado online del usuario actual.
  void _toggleOnlineStatus() {
    final newStatus = !state.isOnline;
    state = state.copyWith(isOnline: newStatus);
    print('🔄 Estado online cambiado a: $newStatus');
  }

  /// Cierra la sesión del usuario actual.
  Future<void> _logout() async {
    try {
      print('🚪 UsersNotifier: Iniciando logout...');
      state = state.copyWith(isLoading: true, message: 'Cerrando sesión...');

      // 1. Desconectar socket antes del logout
      await _ref.read(socketConnectionProvider.notifier).onLogout();

      // 2. Logout del AuthRepository
      await _authRepository.logout();

      // 3. Verificar que el logout fue exitoso
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser != null) {
        throw Exception('El usuario no fue deslogueado correctamente');
      }

      // 4. Actualizar estado de éxito
      state = state.copyWith(
        isLoading: false,
        users: [], // Limpiar lista de usuarios
        message: 'Sesión cerrada exitosamente',
      );

      print('✅ UsersNotifier: Logout exitoso');
    } catch (e) {
      print('❌ UsersNotifier: Error en logout: $e');

      // Intentar cleanup forzado
      try {
        await _ref.read(socketConnectionProvider.notifier).disconnectSocket();
        print('🧹 Cleanup forzado de socket realizado');
      } catch (cleanupError) {
        print('⚠️ Error en cleanup forzado: $cleanupError');
      }

      state = state.copyWith(
        isLoading: false,
        message: 'Error al cerrar sesión: $e',
      );
    }
  }
}
