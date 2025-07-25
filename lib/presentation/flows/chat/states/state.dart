import 'package:chat/domain/entities/message.dart';

/// Estado inmutable del flujo de chat.
///
/// Maneja todo el estado relacionado con la pantalla de chat:
/// - Lista de mensajes
/// - Estado del input de texto
/// - Usuario activo con quien se chatea
/// - Estado de "está escribiendo"
class ChatState {
  /// Lista de mensajes del chat.
  final List<Message> messages;

  /// Texto actual en el input.
  final String currentText;

  /// ID del usuario con quien se está chateando.
  final String? recipientUserId;

  /// Nombre del usuario con quien se está chateando.
  final String? recipientUserName;

  /// Avatar del usuario receptor.
  final String? recipientAvatar;

  /// Si el usuario está escribiendo actualmente.
  final bool isTyping;

  /// Si se está enviando un mensaje.
  final bool isSendingMessage;

  /// Mensaje de error o estado.
  final String? message;

  const ChatState({
    this.messages = const [],
    this.currentText = '',
    this.recipientUserId,
    this.recipientUserName,
    this.recipientAvatar,
    this.isTyping = false,
    this.isSendingMessage = false,
    this.message,
  });

  /// Constructor inicial del estado.
  factory ChatState.initial() {
    return const ChatState();
  }

  ChatState copyWith({
    List<Message>? messages,
    String? currentText,
    String? recipientUserId,
    String? recipientUserName,
    String? recipientAvatar,
    bool? isTyping,
    bool? isSendingMessage,
    String? message,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      currentText: currentText ?? this.currentText,
      recipientUserId: recipientUserId ?? this.recipientUserId,
      recipientUserName: recipientUserName ?? this.recipientUserName,
      recipientAvatar: recipientAvatar ?? this.recipientAvatar,
      isTyping: isTyping ?? this.isTyping,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
      message: message ?? this.message,
    );
  }

  /// Helpers para UI
  bool get hasMessages => messages.isNotEmpty;
  bool get canSendMessage => currentText.trim().isNotEmpty && !isSendingMessage;
  String get displayRecipientName => recipientUserName ?? 'Usuario';
  String get displayRecipientAvatar => recipientAvatar ?? 'U';
}
