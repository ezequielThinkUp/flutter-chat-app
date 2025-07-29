import 'package:chat/domain/entities/message.dart';

/// Modelo de datos para mensajes en la capa de infraestructura.
///
/// Maneja la serialización/deserialización JSON y la conversión
/// hacia entidades de dominio para mensajes de chat.
class MessageModel {
  /// ID único del mensaje.
  final String id;

  /// Contenido del mensaje.
  final String content;

  /// ID del usuario que envió el mensaje.
  final String senderId;

  /// ID del usuario que recibe el mensaje.
  final String receiverId;

  /// Timestamp de cuando se envió el mensaje.
  final DateTime timestamp;

  /// Estado del mensaje.
  final MessageStatus status;

  /// Tipo de mensaje.
  final MessageType type;

  const MessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
    required this.status,
    this.type = MessageType.text,
  });

  /// Crea desde JSON manualmente.
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? '',
      content: json['contenido'] as String? ?? '',
      senderId: json['emisor']?['_id'] as String? ?? '',
      receiverId: json['receptor']?['_id'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      status: _parseMessageStatus(json['estado'] as String? ?? 'enviado'),
      type: _parseMessageType(json['tipo'] as String? ?? 'texto'),
    );
  }

  /// Convierte a entidad de dominio.
  Message toDomain() {
    return Message(
      id: id,
      content: content,
      senderId: senderId,
      receiverId: receiverId,
      timestamp: timestamp,
      status: status,
      type: type,
    );
  }

  /// Crea desde entidad de dominio.
  factory MessageModel.fromDomain(Message message) {
    return MessageModel(
      id: message.id,
      content: message.content,
      senderId: message.senderId,
      receiverId: message.receiverId,
      timestamp: message.timestamp,
      status: message.status,
      type: message.type,
    );
  }

  /// Parsea el estado del mensaje desde string.
  static MessageStatus _parseMessageStatus(String status) {
    switch (status.toLowerCase()) {
      case 'enviando':
        return MessageStatus.sending;
      case 'enviado':
        return MessageStatus.sent;
      case 'entregado':
        return MessageStatus.delivered;
      case 'leido':
        return MessageStatus.read;
      case 'error':
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.sent;
    }
  }

  /// Parsea el tipo de mensaje desde string.
  static MessageType _parseMessageType(String type) {
    switch (type.toLowerCase()) {
      case 'imagen':
        return MessageType.image;
      case 'audio':
        return MessageType.audio;
      case 'archivo':
      case 'file':
        return MessageType.file;
      default:
        return MessageType.text;
    }
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, content: $content, senderId: $senderId, status: $status)';
  }
}
