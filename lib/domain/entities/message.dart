/// Entidad de dominio para representar un mensaje de chat.
///
/// Contiene la lógica de negocio pura para mensajes.
class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status;

  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
  });

  /// Copia el mensaje con nuevos valores.
  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? timestamp,
    MessageType? type,
    MessageStatus? status,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      status: status ?? this.status,
    );
  }

  /// Indica si el mensaje es del usuario especificado.
  bool isFromUser(String userId) => senderId == userId;

  /// Convierte a modelo de datos para persistencia.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'status': status.name,
    };
  }

  /// Crea desde modelo de datos.
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message &&
        other.id == id &&
        other.senderId == senderId &&
        other.receiverId == receiverId &&
        other.content == content &&
        other.timestamp == timestamp &&
        other.type == type &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(
        id,
        senderId,
        receiverId,
        content,
        timestamp,
        type,
        status,
      );

  @override
  String toString() {
    return 'Message(id: $id, from: $senderId, content: $content)';
  }
}

/// Tipos de mensaje disponibles.
enum MessageType {
  text,
  image,
  file,
  audio,
}

/// Estados del mensaje.
enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}
