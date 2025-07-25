import 'dart:async';
import 'package:chat/domain/entities/user.dart';
import 'package:chat/domain/datasources/socket_datasource.dart';

/// Repositorio de Socket para comunicación en tiempo real.
///
/// Maneja la lógica de negocio relacionada con Socket.IO,
/// incluyendo autenticación automática y gestión de conexiones.
abstract class SocketRepository {
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

  /// Conecta y autentica automáticamente con el usuario actual.
  ///
  /// Utiliza el usuario autenticado del AuthRepository.
  /// Throws Exception si no hay usuario autenticado o error de conexión.
  Future<void> connectAndAuthenticate();

  /// Conecta manualmente con un usuario específico.
  ///
  /// [user] Usuario para autenticar en el socket
  /// Throws Exception si hay error en la conexión o autenticación
  Future<bool> connectWithUser(User user);

  /// Envía un mensaje privado a otro usuario.
  ///
  /// [recipientUserId] ID del usuario destinatario
  /// [message] Contenido del mensaje
  /// [type] Tipo de mensaje (texto, imagen, etc.)
  /// Throws Exception si hay error enviando el mensaje
  Future<void> sendPrivateMessage({
    required String recipientUserId,
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
  /// [recipientUserId] ID del usuario al que se está escribiendo
  /// [isTyping] true si está escribiendo, false si dejó de escribir
  /// Throws Exception si hay error enviando el indicador
  Future<void> sendTypingIndicator({
    required String recipientUserId,
    required bool isTyping,
  });

  /// Obtiene la lista de usuarios online.
  ///
  /// Throws Exception si hay error obteniendo los usuarios
  Future<void> refreshOnlineUsers();

  /// Desconecta del socket.
  ///
  /// Cierra la conexión y limpia recursos.
  Future<void> disconnect();

  /// Reconecta automáticamente con el último usuario.
  ///
  /// Útil para recuperar conexión después de pérdida de red.
  /// Returns true si la reconexión fue exitosa
  Future<bool> reconnect();
}
