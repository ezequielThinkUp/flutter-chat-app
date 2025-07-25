import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Servicio HTTP-like para Socket.IO usando socket_io_client.
///
/// Wrapper directo del cliente Socket.IO para comunicación en tiempo real.
class SocketService {
  late IO.Socket _socket;
  bool _isConnected = false;

  // StreamControllers para eventos
  final _connectionController = StreamController<bool>.broadcast();
  final _messagesController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _usersController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();

  /// Estado de conexión del socket.
  bool get isConnected => _isConnected;

  /// Stream de estado de conexión.
  Stream<bool> get connectionStatus => _connectionController.stream;

  /// Stream de mensajes recibidos.
  Stream<Map<String, dynamic>> get messages => _messagesController.stream;

  /// Stream de usuarios online.
  Stream<List<Map<String, dynamic>>> get usersOnline => _usersController.stream;

  /// Stream de indicadores de escritura.
  Stream<Map<String, dynamic>> get typingIndicators => _typingController.stream;

  /// Conecta al servidor Socket.IO.
  Future<void> connect(String serverUrl) async {
    try {
      print('🔌 SocketService: Conectando a $serverUrl...');

      _socket = IO.io(
          serverUrl,
          IO.OptionBuilder()
              .setTransports(['websocket', 'polling'])
              .enableAutoConnect()
              .enableReconnection()
              .setReconnectionAttempts(5)
              .setReconnectionDelay(1000)
              .setTimeout(10000)
              .build());

      _setupEventListeners();

      // Esperar conexión con timeout
      final completer = Completer<void>();
      Timer? timeoutTimer;

      _socket.onConnect((_) {
        _isConnected = true;
        _connectionController.add(true);
        timeoutTimer?.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
        print('✅ SocketService: Conectado exitosamente');
      });

      _socket.onConnectError((error) {
        timeoutTimer?.cancel();
        if (!completer.isCompleted) {
          completer.completeError('Error de conexión: $error');
        }
      });

      timeoutTimer = Timer(const Duration(seconds: 10), () {
        if (!completer.isCompleted) {
          completer.completeError('Timeout de conexión');
        }
      });

      _socket.connect();
      await completer.future;
    } catch (e) {
      print('❌ SocketService: Error conectando: $e');
      throw Exception('Error conectando al socket: $e');
    }
  }

  /// Configura los listeners de eventos del socket.
  void _setupEventListeners() {
    // Eventos de conexión
    _socket.onDisconnect((_) {
      _isConnected = false;
      _connectionController.add(false);
      print('❌ SocketService: Desconectado');
    });

    // Eventos de autenticación
    _socket.on('login-ok', (data) {
      print('✅ SocketService: Login exitoso');
      _handleLoginSuccess(data);
    });

    _socket.on('login-error', (data) {
      print('❌ SocketService: Error de login: $data');
    });

    // Eventos de mensajes
    _socket.on('mensaje', (data) {
      print('💬 SocketService: Mensaje público recibido');
      _messagesController.add(data);
    });

    _socket.on('mensaje-personal', (data) {
      print('💌 SocketService: Mensaje privado recibido');
      _messagesController.add(data);
    });

    _socket.on('mensaje-enviado', (data) {
      print('📤 SocketService: Confirmación de mensaje enviado');
      _messagesController.add(data);
    });

    // Eventos de usuarios
    _socket.on('usuario-conectado', (data) {
      print('👤 SocketService: Usuario conectado');
    });

    _socket.on('usuario-desconectado', (data) {
      print('👤 SocketService: Usuario desconectado');
    });

    _socket.on('usuarios-online', (data) {
      print('👥 SocketService: Lista de usuarios online recibida');
      if (data is Map && data['usuarios'] is List) {
        _usersController.add(List<Map<String, dynamic>>.from(data['usuarios']));
      }
    });

    // Eventos de escritura
    _socket.on('escribiendo', (data) {
      print('✏️ SocketService: Indicador de escritura');
      _typingController.add(data);
    });

    // Eventos de error
    _socket.onError((error) {
      print('🚨 SocketService: Error: $error');
    });
  }

  /// Maneja el login exitoso.
  void _handleLoginSuccess(dynamic data) {
    if (data is Map && data['usuariosOnline'] is List) {
      _usersController
          .add(List<Map<String, dynamic>>.from(data['usuariosOnline']));
    }
  }

  /// Autentica el usuario en el socket.
  Future<bool> authenticate(Map<String, dynamic> userData) async {
    try {
      print('🔐 SocketService: Autenticando usuario...');

      final completer = Completer<bool>();
      Timer? timeoutTimer;

      // Listener para respuesta exitosa
      _socket.once('login-ok', (data) {
        timeoutTimer?.cancel();
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      });

      // Listener para error
      _socket.once('login-error', (data) {
        timeoutTimer?.cancel();
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      });

      // Timeout
      timeoutTimer = Timer(const Duration(seconds: 5), () {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      });

      // Enviar datos de autenticación
      _socket.emit('login', userData);

      return await completer.future;
    } catch (e) {
      print('❌ SocketService: Error en autenticación: $e');
      return false;
    }
  }

  /// Envía un mensaje privado.
  void sendPrivateMessage({
    required String recipientUid,
    required String message,
    String type = 'texto',
  }) {
    if (!_isConnected) {
      throw Exception('Socket no conectado');
    }

    _socket.emit('mensaje-personal', {
      'para': recipientUid,
      'mensaje': message,
      'tipo': type,
    });
  }

  /// Envía un mensaje público.
  void sendPublicMessage(String message) {
    if (!_isConnected) {
      throw Exception('Socket no conectado');
    }

    _socket.emit('mensaje', message);
  }

  /// Envía indicador de escritura.
  void sendTypingIndicator({
    required String recipientUid,
    required bool isTyping,
  }) {
    if (!_isConnected) return;

    _socket.emit('escribiendo', {
      'para': recipientUid,
      'escribiendo': isTyping,
    });
  }

  /// Solicita la lista de usuarios online.
  void getOnlineUsers() {
    if (!_isConnected) return;

    _socket.emit('obtener-usuarios');
  }

  /// Desconecta del socket.
  void disconnect() {
    if (_isConnected) {
      _socket.disconnect();
      _isConnected = false;
      _connectionController.add(false);
      print('🔌 SocketService: Desconectado manualmente');
    }
  }

  /// Limpia recursos.
  void dispose() {
    disconnect();
    _connectionController.close();
    _messagesController.close();
    _usersController.close();
    _typingController.close();
  }
}

/// Provider para el servicio de Socket.
final socketServiceProvider = Provider<SocketService>(
  (ref) => SocketService(),
);
