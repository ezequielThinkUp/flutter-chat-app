import 'dart:async';
import 'package:chat/domain/datasources/socket_datasource.dart';
import 'package:chat/domain/entities/user.dart';
import 'package:chat/infrastructure/services/socket_service.dart';

/// Implementación remota del DataSource de Socket.
///
/// Se comunica con el servidor Socket.IO a través del SocketService.
/// Maneja la conversión entre entidades de dominio y modelos de servicio.
class SocketRemoteDataSource implements SocketDataSource {
  final SocketService _socketService;

  // StreamControllers para transformar datos
  final _usersController = StreamController<List<User>>.broadcast();
  final _messagesController = StreamController<SocketMessage>.broadcast();
  final _typingController = StreamController<TypingIndicator>.broadcast();

  late StreamSubscription _usersSubscription;
  late StreamSubscription _messagesSubscription;
  late StreamSubscription _typingSubscription;

  SocketRemoteDataSource(this._socketService) {
    _setupStreamTransformations();
  }

  /// Configura las transformaciones de streams.
  void _setupStreamTransformations() {
    // Transformar usuarios de Map a User entities
    _usersSubscription = _socketService.usersOnline.listen((userMaps) {
      try {
        final users = userMaps.map((map) => _mapToUser(map)).toList();
        _usersController.add(users);
      } catch (e) {
        print('❌ SocketRemoteDataSource: Error transformando usuarios: $e');
        _usersController.add([]);
      }
    });

    // Transformar mensajes de Map a SocketMessage
    _messagesSubscription = _socketService.messages.listen((messageMap) {
      try {
        final message = SocketMessage.fromJson(messageMap);
        _messagesController.add(message);
      } catch (e) {
        print('❌ SocketRemoteDataSource: Error transformando mensaje: $e');
      }
    });

    // Transformar indicadores de escritura
    _typingSubscription = _socketService.typingIndicators.listen((typingMap) {
      try {
        final indicator = TypingIndicator.fromJson(typingMap);
        _typingController.add(indicator);
      } catch (e) {
        print('❌ SocketRemoteDataSource: Error transformando typing: $e');
      }
    });
  }

  /// Convierte un Map a User entity.
  User _mapToUser(Map<String, dynamic> map) {
    return User(
      id: map['uid'] ?? '',
      name: map['nombre'] ?? '',
      email: map['email'] ?? '',
      isOnline: map['online'] ?? false,
    );
  }

  @override
  bool get isConnected => _socketService.isConnected;

  @override
  Stream<bool> get connectionStatus => _socketService.connectionStatus;

  @override
  Stream<List<User>> get usersOnline => _usersController.stream;

  @override
  Stream<SocketMessage> get messages => _messagesController.stream;

  @override
  Stream<TypingIndicator> get typingIndicators => _typingController.stream;

  @override
  Future<void> connect(String serverUrl) async {
    try {
      print('🌐 SocketRemoteDataSource: Conectando a $serverUrl...');
      await _socketService.connect(serverUrl);
      print('✅ SocketRemoteDataSource: Conexión exitosa');
    } catch (e) {
      print('❌ SocketRemoteDataSource: Error conectando: $e');
      throw Exception('Error conectando al socket: $e');
    }
  }

  @override
  Future<bool> authenticate(User user) async {
    try {
      print('🔐 SocketRemoteDataSource: Autenticando usuario ${user.name}...');

      final userData = {
        'nombre': user.name,
        'uid': user.id,
        'email': user.email,
      };

      final success = await _socketService.authenticate(userData);

      if (success) {
        print('✅ SocketRemoteDataSource: Autenticación exitosa');
      } else {
        print('❌ SocketRemoteDataSource: Fallo en autenticación');
      }

      return success;
    } catch (e) {
      print('❌ SocketRemoteDataSource: Error en autenticación: $e');
      throw Exception('Error autenticando usuario: $e');
    }
  }

  @override
  Future<void> sendPrivateMessage({
    required String recipientUid,
    required String message,
    String type = 'texto',
  }) async {
    try {
      print(
          '💌 SocketRemoteDataSource: Enviando mensaje privado a $recipientUid...');

      _socketService.sendPrivateMessage(
        recipientUid: recipientUid,
        message: message,
        type: type,
      );

      print('✅ SocketRemoteDataSource: Mensaje privado enviado');
    } catch (e) {
      print('❌ SocketRemoteDataSource: Error enviando mensaje privado: $e');
      throw Exception('Error enviando mensaje privado: $e');
    }
  }

  @override
  Future<void> sendPublicMessage(String message) async {
    try {
      print('💬 SocketRemoteDataSource: Enviando mensaje público...');

      _socketService.sendPublicMessage(message);

      print('✅ SocketRemoteDataSource: Mensaje público enviado');
    } catch (e) {
      print('❌ SocketRemoteDataSource: Error enviando mensaje público: $e');
      throw Exception('Error enviando mensaje público: $e');
    }
  }

  @override
  Future<void> sendTypingIndicator({
    required String recipientUid,
    required bool isTyping,
  }) async {
    try {
      _socketService.sendTypingIndicator(
        recipientUid: recipientUid,
        isTyping: isTyping,
      );
    } catch (e) {
      print('❌ SocketRemoteDataSource: Error enviando typing indicator: $e');
      throw Exception('Error enviando typing indicator: $e');
    }
  }

  @override
  Future<void> getOnlineUsers() async {
    try {
      print('👥 SocketRemoteDataSource: Solicitando usuarios online...');
      _socketService.getOnlineUsers();
    } catch (e) {
      print('❌ SocketRemoteDataSource: Error obteniendo usuarios online: $e');
      throw Exception('Error obteniendo usuarios online: $e');
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      print('🔌 SocketRemoteDataSource: Desconectando...');
      _socketService.disconnect();
      print('✅ SocketRemoteDataSource: Desconectado');
    } catch (e) {
      print('❌ SocketRemoteDataSource: Error desconectando: $e');
    }
  }

  /// Limpia recursos.
  void dispose() {
    _usersSubscription.cancel();
    _messagesSubscription.cancel();
    _typingSubscription.cancel();
    _usersController.close();
    _messagesController.close();
    _typingController.close();
    _socketService.dispose();
  }
}
