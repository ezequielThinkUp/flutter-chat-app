import 'dart:async';
import 'package:chat/domain/entities/user.dart';

/// Interface que define las operaciones de Socket para comunicación en tiempo real.
///
/// Esta abstracción permite cambiar la implementación de Socket
/// sin afectar la lógica del repositorio.
abstract class SocketDataSource {
  /// Estado de conexión del socket.
  bool get isConnected;

  /// Stream de conexión del socket.
  Stream<bool> get connectionStatus;

  /// Stream de usuarios online.
  Stream<List<User>> get usersOnline;

  /// Stream de mensajes recibidos.
  Stream<SocketMessage> get messages;

  /// Stream de indicadores de escritura.
  Stream<TypingIndicator> get typingIndicators;

  /// Conecta al servidor Socket.IO.
  ///
  /// [serverUrl] URL del servidor Socket.IO
  /// Throws Exception si hay error en la conexión
  Future<void> connect(String serverUrl);

  /// Autentica el usuario en el socket.
  ///
  /// [user] Datos del usuario para autenticación
  /// Returns true si la autenticación fue exitosa
  /// Throws Exception si hay error en la autenticación
  Future<bool> authenticate(User user);

  /// Envía un mensaje privado a otro usuario.
  ///
  /// [recipientUid] UID del usuario destinatario
  /// [message] Contenido del mensaje
  /// [type] Tipo de mensaje (texto, imagen, etc.)
  /// Throws Exception si hay error enviando el mensaje
  Future<void> sendPrivateMessage({
    required String recipientUid,
    required String message,
    String type = 'texto',
  });

  /// Envía un mensaje público (broadcast).
  ///
  /// [message] Contenido del mensaje
  /// Throws Exception si hay error enviando el mensaje
  Future<void> sendPublicMessage(String message);

  /// Envía indicador de escritura.
  ///
  /// [recipientUid] UID del usuario al que se está escribiendo
  /// [isTyping] true si está escribiendo, false si dejó de escribir
  /// Throws Exception si hay error enviando el indicador
  Future<void> sendTypingIndicator({
    required String recipientUid,
    required bool isTyping,
  });

  /// Obtiene la lista de usuarios online.
  ///
  /// Throws Exception si hay error obteniendo los usuarios
  Future<void> getOnlineUsers();

  /// Desconecta del servidor Socket.IO.
  Future<void> disconnect();
}

/// Modelo para mensajes de Socket.
class SocketMessage {
  final String from;
  final String? to;
  final String message;
  final String type;
  final DateTime timestamp;
  final String senderName;
  final bool? delivered;

  const SocketMessage({
    required this.from,
    this.to,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.senderName,
    this.delivered,
  });

  factory SocketMessage.fromJson(Map<String, dynamic> json) {
    return SocketMessage(
      from: json['de'] ?? json['uid'] ?? '',
      to: json['para'],
      message: json['mensaje'] ?? '',
      type: json['tipo'] ?? 'texto',
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
      senderName: json['nombreEmisor'] ?? json['usuario'] ?? '',
      delivered: json['entregado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'de': from,
      'para': to,
      'mensaje': message,
      'tipo': type,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'nombreEmisor': senderName,
      'entregado': delivered,
    };
  }
}

/// Modelo para indicadores de escritura.
class TypingIndicator {
  final String from;
  final String name;
  final bool isTyping;

  const TypingIndicator({
    required this.from,
    required this.name,
    required this.isTyping,
  });

  factory TypingIndicator.fromJson(Map<String, dynamic> json) {
    return TypingIndicator(
      from: json['de'] ?? '',
      name: json['nombre'] ?? '',
      isTyping: json['escribiendo'] ?? false,
    );
  }
}
