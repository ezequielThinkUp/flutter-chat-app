import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/domain/repositories/auth_repository.dart';
import 'package:chat/domain/repositories/socket_repository.dart';
import 'package:chat/infrastructure/providers/repositories/auth_repository_provider.dart';
import 'package:chat/infrastructure/providers/repositories/socket_repository_provider.dart';

/// Estado de la conexión automática de Socket.
class SocketConnectionState {
  final bool isConnecting;
  final bool isConnected;
  final bool isAuthenticated;
  final String? error;
  final String? message;

  const SocketConnectionState({
    this.isConnecting = false,
    this.isConnected = false,
    this.isAuthenticated = false,
    this.error,
    this.message,
  });

  SocketConnectionState copyWith({
    bool? isConnecting,
    bool? isConnected,
    bool? isAuthenticated,
    String? error,
    String? message,
  }) {
    return SocketConnectionState(
      isConnecting: isConnecting ?? this.isConnecting,
      isConnected: isConnected ?? this.isConnected,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error ?? this.error,
      message: message ?? this.message,
    );
  }
}

/// Notifier que maneja la conexión automática de Socket basada en autenticación.
///
/// Se conecta automáticamente cuando el usuario se autentica
/// y se desconecta cuando cierra sesión.
class SocketConnectionNotifier extends StateNotifier<SocketConnectionState> {
  final SocketRepository _socketRepository;
  final AuthRepository _authRepository;

  SocketConnectionNotifier(this._socketRepository, this._authRepository)
      : super(const SocketConnectionState()) {
    _initializeConnection();
  }

  /// Inicializa la conexión verificando si hay un usuario autenticado.
  Future<void> _initializeConnection() async {
    print('🔌 SocketConnectionNotifier: Inicializando...');

    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        print('✅ Usuario autenticado encontrado, conectando socket...');
        await connectSocket();
      } else {
        print('ℹ️ No hay usuario autenticado, socket no conectado');
      }
    } catch (e) {
      print('❌ Error inicializando conexión socket: $e');
      state = state.copyWith(
        error: 'Error inicializando socket: $e',
        message: 'Error en inicialización',
      );
    }
  }

  /// Conecta el socket con el usuario autenticado.
  Future<void> connectSocket() async {
    if (state.isConnecting) {
      print('⚠️ Socket ya conectando, ignorando solicitud duplicada');
      return;
    }

    try {
      state = state.copyWith(
        isConnecting: true,
        error: null,
        message: 'Conectando socket...',
      );

      print('🔌 SocketConnectionNotifier: Conectando socket...');
      print('🔌 Llamando a _socketRepository.connectAndAuthenticate()...');

      await _socketRepository.connectAndAuthenticate();

      state = state.copyWith(
        isConnecting: false,
        isConnected: true,
        isAuthenticated: true,
        message: 'Socket conectado y autenticado',
      );

      print('✅ SocketConnectionNotifier: Socket conectado exitosamente');
    } catch (e) {
      print('❌ SocketConnectionNotifier: Error conectando: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      state = state.copyWith(
        isConnecting: false,
        isConnected: false,
        isAuthenticated: false,
        error: e.toString(),
        message: 'Error conectando socket',
      );
    }
  }

  /// Desconecta el socket.
  Future<void> disconnectSocket() async {
    try {
      print('🔌 SocketConnectionNotifier: Desconectando socket...');

      await _socketRepository.disconnect();

      state = state.copyWith(
        isConnecting: false,
        isConnected: false,
        isAuthenticated: false,
        error: null,
        message: 'Socket desconectado',
      );

      print('✅ SocketConnectionNotifier: Socket desconectado');
    } catch (e) {
      print('❌ SocketConnectionNotifier: Error desconectando: $e');
      state = state.copyWith(
        error: e.toString(),
        message: 'Error desconectando socket',
      );
    }
  }

  /// Reconecta el socket.
  Future<void> reconnectSocket() async {
    try {
      print('🔄 SocketConnectionNotifier: Reconectando socket...');

      state = state.copyWith(
        isConnecting: true,
        error: null,
        message: 'Reconectando socket...',
      );

      final success = await _socketRepository.reconnect();

      if (success) {
        state = state.copyWith(
          isConnecting: false,
          isConnected: true,
          isAuthenticated: true,
          message: 'Socket reconectado exitosamente',
        );
      } else {
        state = state.copyWith(
          isConnecting: false,
          isConnected: false,
          isAuthenticated: false,
          error: 'Error en reconexión',
          message: 'Fallo al reconectar socket',
        );
      }
    } catch (e) {
      print('❌ SocketConnectionNotifier: Error reconectando: $e');
      state = state.copyWith(
        isConnecting: false,
        isConnected: false,
        isAuthenticated: false,
        error: e.toString(),
        message: 'Error reconectando socket',
      );
    }
  }

  /// Maneja eventos de login exitoso.
  Future<void> onLoginSuccess() async {
    print('🎉 SocketConnectionNotifier: Login detectado, conectando socket...');
    print('🎉 Verificando usuario autenticado...');

    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        print('✅ Usuario encontrado: ${user.name} (${user.id})');
      } else {
        print('❌ No hay usuario autenticado disponible');
      }

      await connectSocket();
    } catch (e) {
      print('❌ Error en onLoginSuccess: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
  }

  /// Maneja eventos de logout.
  Future<void> onLogout() async {
    print(
        '🚪 SocketConnectionNotifier: Logout detectado, desconectando socket...');
    await disconnectSocket();
  }

  /// Acceso directo al SocketRepository.
  SocketRepository get socketRepository => _socketRepository;
}

/// Provider para la conexión automática de Socket.
final socketConnectionProvider =
    StateNotifierProvider<SocketConnectionNotifier, SocketConnectionState>(
  (ref) {
    final socketRepository = ref.watch(socketRepositoryProvider);
    final authRepository = ref.watch(authRepositoryProvider);
    return SocketConnectionNotifier(socketRepository, authRepository);
  },
);

/// Provider de conveniencia para acceder al SocketRepository.
final connectedSocketRepositoryProvider = Provider<SocketRepository>(
  (ref) => ref.read(socketConnectionProvider.notifier).socketRepository,
);
