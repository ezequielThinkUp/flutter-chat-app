import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/domain/datasources/socket_datasource.dart';
import 'package:chat/infrastructure/providers/datasources/socket_datasource_provider.dart';
import 'package:chat/global/environment.dart';
import 'package:chat/domain/entities/user.dart';

/// Provider de prueba para demostrar la conexión Socket.
///
/// Maneja la conexión automática y autenticación con el servidor.
class SocketTestNotifier extends StateNotifier<SocketTestState> {
  final SocketDataSource _socketDataSource;

  SocketTestNotifier(this._socketDataSource) : super(const SocketTestState());

  /// Conecta y autentica automáticamente.
  Future<void> connectAndAuthenticate() async {
    try {
      state = state.copyWith(isLoading: true, message: 'Conectando...');

      // Conectar al servidor
      await _socketDataSource.connect(Environment.socketUrl);

      state = state.copyWith(
        isConnected: true,
        message: 'Conectado. Autenticando...',
      );

      // Crear usuario de prueba
      final testUser = User(
        id: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Usuario Test Flutter',
        email: 'test@flutter.com',
        isOnline: true,
      );

      // Autenticar usuario
      final authenticated = await _socketDataSource.authenticate(testUser);

      if (authenticated) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          currentUser: testUser,
          message: 'Conectado y autenticado exitosamente',
        );

        // Solicitar usuarios online
        await _socketDataSource.getOnlineUsers();

        // Escuchar streams
        _listenToStreams();
      } else {
        state = state.copyWith(
          isLoading: false,
          message: 'Error en autenticación',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        message: 'Error: $e',
      );
    }
  }

  /// Escucha los streams del socket.
  void _listenToStreams() {
    // Stream de usuarios online
    _socketDataSource.usersOnline.listen((users) {
      state = state.copyWith(onlineUsers: users);
    });

    // Stream de mensajes
    _socketDataSource.messages.listen((message) {
      final newMessages = [...state.messages, message];
      state = state.copyWith(messages: newMessages);
    });

    // Stream de conexión
    _socketDataSource.connectionStatus.listen((connected) {
      state = state.copyWith(isConnected: connected);
    });
  }

  /// Envía un mensaje de prueba.
  Future<void> sendTestMessage() async {
    if (!state.isAuthenticated) return;

    try {
      await _socketDataSource.sendPublicMessage('¡Hola desde Flutter! 🚀');

      final newMessages = [...state.messages];
      state = state.copyWith(messages: newMessages);
    } catch (e) {
      state = state.copyWith(message: 'Error enviando mensaje: $e');
    }
  }

  /// Desconecta del socket.
  Future<void> disconnect() async {
    try {
      await _socketDataSource.disconnect();
      state = const SocketTestState();
    } catch (e) {
      state = state.copyWith(message: 'Error desconectando: $e');
    }
  }
}

/// Estado para el test del socket.
class SocketTestState {
  final bool isLoading;
  final bool isConnected;
  final bool isAuthenticated;
  final User? currentUser;
  final List<User> onlineUsers;
  final List<dynamic> messages;
  final String message;

  const SocketTestState({
    this.isLoading = false,
    this.isConnected = false,
    this.isAuthenticated = false,
    this.currentUser,
    this.onlineUsers = const [],
    this.messages = const [],
    this.message = '',
  });

  SocketTestState copyWith({
    bool? isLoading,
    bool? isConnected,
    bool? isAuthenticated,
    User? currentUser,
    List<User>? onlineUsers,
    List<dynamic>? messages,
    String? message,
  }) {
    return SocketTestState(
      isLoading: isLoading ?? this.isLoading,
      isConnected: isConnected ?? this.isConnected,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentUser: currentUser ?? this.currentUser,
      onlineUsers: onlineUsers ?? this.onlineUsers,
      messages: messages ?? this.messages,
      message: message ?? this.message,
    );
  }
}

/// Provider para el test del socket.
final socketTestProvider =
    StateNotifierProvider<SocketTestNotifier, SocketTestState>(
  (ref) {
    final socketDataSource = ref.watch(socketDataSourceProvider);
    return SocketTestNotifier(socketDataSource);
  },
);
