import 'package:chat/presentation/base/base_action.dart';

/// Acciones disponibles en el flujo de chat.
///
/// Utilizamos sealed classes para garantizar que todas las acciones
/// sean manejadas correctamente en el notifier.
sealed class ChatAction extends BaseAction {
  const ChatAction();
}

/// Inicializar el chat con un usuario específico.
class InitializeChat extends ChatAction {
  final String recipientUserId;
  final String recipientUserName;
  final String? recipientAvatar;

  const InitializeChat({
    required this.recipientUserId,
    required this.recipientUserName,
    this.recipientAvatar,
  });

  List<Object?> get props =>
      [recipientUserId, recipientUserName, recipientAvatar];
}

/// Actualizar el texto del input.
class UpdateMessageText extends ChatAction {
  final String text;

  const UpdateMessageText(this.text);

  List<Object?> get props => [text];
}

/// Enviar un mensaje.
class SendMessage extends ChatAction {
  final String text;

  const SendMessage(this.text);

  List<Object?> get props => [text];
}

/// Cargar mensajes del chat.
class LoadMessages extends ChatAction {
  const LoadMessages();

  List<Object?> get props => [];
}

/// Limpiar el chat.
class ClearChat extends ChatAction {
  const ClearChat();

  List<Object?> get props => [];
}

/// Marcar mensajes como leídos.
class MarkMessagesAsRead extends ChatAction {
  const MarkMessagesAsRead();

  List<Object?> get props => [];
}

/// Actualizar estado de "está escribiendo".
class UpdateTypingStatus extends ChatAction {
  final bool isTyping;

  const UpdateTypingStatus(this.isTyping);

  List<Object?> get props => [isTyping];
}

/// Marcar un mensaje específico como leído.
class MarkMessageAsRead extends ChatAction {
  final String messageId;

  const MarkMessageAsRead(this.messageId);

  List<Object?> get props => [messageId];
}

/// Marcar un mensaje específico como entregado.
class MarkMessageAsDelivered extends ChatAction {
  final String messageId;

  const MarkMessageAsDelivered(this.messageId);

  List<Object?> get props => [messageId];
}

/// Refrescar mensajes del chat.
class RefreshMessages extends ChatAction {
  const RefreshMessages();

  List<Object?> get props => [];
}

/// Limpiar mensaje de error/estado.
class ClearMessage extends ChatAction {
  const ClearMessage();

  List<Object?> get props => [];
}
