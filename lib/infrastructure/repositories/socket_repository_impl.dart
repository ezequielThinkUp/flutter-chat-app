import 'dart:async';
import 'package:chat/domain/entities/user.dart';
import 'package:chat/domain/repositories/socket_repository.dart';
import 'package:chat/domain/repositories/auth_repository.dart';
import 'package:chat/domain/datasources/socket_datasource.dart';
import 'package:chat/global/environment.dart';

/// Implementación del repositorio de Socket.
///
/// Coordina las operaciones entre SocketDataSource y AuthRepository.
/// Maneja la autenticación automática con el usuario logueado.
class SocketRepositoryImpl implements SocketRepository {
  final SocketDataSource _socketDataSource;
  final AuthRepository _authRepository;

  User? _currentUser;
  bool _isInitialized = false;

  SocketRepositoryImpl(this._socketDataSource, this._authRepository);

  @override
  bool get isConnected => _socketDataSource.isConnected;

  @override
  Stream<bool> get connectionStatus => _socketDataSource.connectionStatus;

  @override
  Stream<List<User>> get usersOnline => _socketDataSource.usersOnline;

  @override
  Stream<SocketMessage> get messages => _socketDataSource.messages;

  @override
  Stream<TypingIndicator> get typingIndicators =>
      _socketDataSource.typingIndicators;

  @override
  Future<void> connectAndAuthenticate() async {
    try {
      print('🔌 SocketRepository: Conectando con usuario autenticado...');

      // 1. Obtener usuario autenticado
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        throw Exception('No hay usuario autenticado para conectar socket');
      }

      print(
          '👤 SocketRepository: Usuario encontrado: ${user.name} (${user.id})');

      // 2. Conectar al servidor
      await _socketDataSource.connect(Environment.socketUrl);
      print('🌐 SocketRepository: Conectado al servidor');

      // 3. Autenticar usuario
      final authenticated = await _socketDataSource.authenticate(user);
      if (!authenticated) {
        throw Exception('Error en autenticación del socket');
      }

      // 4. Guardar usuario actual y marcar como inicializado
      _currentUser = user;
      _isInitialized = true;

      print('✅ SocketRepository: Conectado y autenticado exitosamente');

      // 5. Solicitar usuarios online
      await _socketDataSource.getOnlineUsers();
    } catch (e) {
      print('❌ SocketRepository: Error en connectAndAuthenticate: $e');
      _isInitialized = false;
      _currentUser = null;
      rethrow;
    }
  }

  @override
  Future<bool> connectWithUser(User user) async {
    try {
      print(
          '🔌 SocketRepository: Conectando con usuario específico: ${user.name}');

      // 1. Conectar al servidor
      await _socketDataSource.connect(Environment.socketUrl);

      // 2. Autenticar usuario
      final authenticated = await _socketDataSource.authenticate(user);
      if (authenticated) {
        _currentUser = user;
        _isInitialized = true;
        await _socketDataSource.getOnlineUsers();
        print('✅ SocketRepository: Conexión manual exitosa');
      }

      return authenticated;
    } catch (e) {
      print('❌ SocketRepository: Error en connectWithUser: $e');
      _isInitialized = false;
      _currentUser = null;
      return false;
    }
  }

  @override
  Future<void> sendPrivateMessage({
    required String recipientUserId,
    required String message,
    String type = 'texto',
  }) async {
    _ensureConnected('enviar mensaje privado');

    try {
      await _socketDataSource.sendPrivateMessage(
        recipientUid: recipientUserId,
        message: message,
        type: type,
      );
      print('💌 SocketRepository: Mensaje privado enviado a $recipientUserId');
    } catch (e) {
      print('❌ SocketRepository: Error enviando mensaje privado: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendPublicMessage(String message) async {
    _ensureConnected('enviar mensaje público');

    try {
      await _socketDataSource.sendPublicMessage(message);
      print('💬 SocketRepository: Mensaje público enviado');
    } catch (e) {
      print('❌ SocketRepository: Error enviando mensaje público: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendTypingIndicator({
    required String recipientUserId,
    required bool isTyping,
  }) async {
    if (!isConnected) return; // No es crítico, no fallar

    try {
      await _socketDataSource.sendTypingIndicator(
        recipientUid: recipientUserId,
        isTyping: isTyping,
      );
    } catch (e) {
      print('⚠️ SocketRepository: Error enviando typing indicator: $e');
      // No relanzar el error, no es crítico
    }
  }

  @override
  Future<void> refreshOnlineUsers() async {
    _ensureConnected('obtener usuarios online');

    try {
      await _socketDataSource.getOnlineUsers();
      print('👥 SocketRepository: Lista de usuarios solicitada');
    } catch (e) {
      print('❌ SocketRepository: Error obteniendo usuarios: $e');
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      print('🔌 SocketRepository: Desconectando...');
      await _socketDataSource.disconnect();
      _isInitialized = false;
      _currentUser = null;
      print('✅ SocketRepository: Desconectado y recursos limpiados');
    } catch (e) {
      print('❌ SocketRepository: Error desconectando: $e');
      // Limpiar estado de todos modos
      _isInitialized = false;
      _currentUser = null;
    }
  }

  @override
  Future<bool> reconnect() async {
    try {
      print('🔄 SocketRepository: Intentando reconectar...');

      if (_currentUser != null) {
        // Usar el último usuario conocido
        return await connectWithUser(_currentUser!);
      } else {
        // Intentar con el usuario autenticado actual
        await connectAndAuthenticate();
        return true;
      }
    } catch (e) {
      print('❌ SocketRepository: Error en reconexión: $e');
      return false;
    }
  }

  /// Verifica que esté conectado antes de operaciones críticas.
  void _ensureConnected(String operation) {
    if (!isConnected || !_isInitialized) {
      throw Exception('Socket no conectado. No se puede $operation');
    }
  }

  /// Obtiene información del usuario actual conectado.
  User? get currentUser => _currentUser;

  /// Indica si el socket está inicializado correctamente.
  bool get isInitialized => _isInitialized;
}
