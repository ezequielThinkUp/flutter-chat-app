import 'package:chat/presentation/base/base_state_notifier.dart';
import 'package:chat/presentation/flows/chat/states/state.dart';
import 'package:chat/presentation/flows/chat/states/action.dart';
import 'package:chat/domain/entities/message.dart';

/// Notifier del flujo de chat.
///
/// Maneja toda la lógica de negocio relacionada con el chat:
/// - Envío y recepción de mensajes
/// - Estado del input de texto
/// - Gestión de usuarios conectados
/// - Integración con socket para tiempo real
class ChatNotifier extends BaseStateNotifier<ChatState, ChatAction> {
  /// ID del usuario actual (hardcoded por ahora).
  static const String _currentUserId = '123';

  ChatNotifier() : super(ChatState.initial());

  @override
  Future<void> handleAction(ChatAction action) async {
    switch (action) {
      case InitializeChat():
        await _handleInitializeChat(action);
        break;
      case UpdateMessageText():
        _handleUpdateMessageText(action);
        break;
      case SendMessage():
        await _handleSendMessage(action);
        break;
      case LoadMessages():
        await _handleLoadMessages();
        break;
      case ClearChat():
        _handleClearChat();
        break;
      case MarkMessagesAsRead():
        _handleMarkMessagesAsRead();
        break;
      case UpdateTypingStatus():
        _handleUpdateTypingStatus(action);
        break;
    }
  }

  /// Inicializa el chat con un usuario específico.
  Future<void> _handleInitializeChat(InitializeChat action) async {
    updateState((state) => state.copyWith(
          recipientUserId: action.recipientUserId,
          recipientUserName: action.recipientUserName,
          recipientAvatar: action.recipientAvatar,
          messages: [], // Chat vacío inicialmente
          currentText: '',
        ));

    // TODO: Cargar mensajes reales del servidor cuando esté implementado
    // await _handleLoadMessages();
  }

  /// Actualiza el texto del input.
  void _handleUpdateMessageText(UpdateMessageText action) {
    updateState((state) => state.copyWith(currentText: action.text));
  }

  /// Envía un mensaje.
  Future<void> _handleSendMessage(SendMessage action) async {
    if (action.text.trim().isEmpty || state.isSendingMessage) return;

    try {
      updateState((state) => state.copyWith(isSendingMessage: true));

      // Crear el mensaje local inmediatamente
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: action.text.trim(),
        senderId: _currentUserId,
        receiverId: state.recipientUserId ?? '',
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );

      // Agregar mensaje a la lista
      final updatedMessages = [...state.messages, message];
      updateState((state) => state.copyWith(
            messages: updatedMessages,
            currentText: '', // Limpiar input
            isSendingMessage: false,
          ));

      // TODO: Enviar mensaje al servidor via socket
      // await _socketService.sendMessage(message);

      print('💬 Mensaje enviado: ${message.content}');
    } catch (e) {
      updateState((state) => state.copyWith(
            isSendingMessage: false,
            message: 'Error al enviar mensaje: $e',
          ));
    }
  }

  /// Carga los mensajes del chat.
  Future<void> _handleLoadMessages() async {
    try {
      // TODO: Cargar mensajes reales del servidor
      // final messages = await _chatService.getMessages(recipientId);

      // Simular carga de mensajes
      await Future.delayed(const Duration(milliseconds: 500));

      final mockMessages = [
        Message(
          id: '1',
          content: '¡Hola! ¿Cómo estás?',
          senderId: state.recipientUserId ?? '',
          receiverId: _currentUserId,
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
          status: MessageStatus.read,
        ),
        Message(
          id: '2',
          content: 'Todo bien, ¿y tú?',
          senderId: _currentUserId,
          receiverId: state.recipientUserId ?? '',
          timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
          status: MessageStatus.read,
        ),
      ];

      updateState((state) => state.copyWith(messages: mockMessages));
    } catch (e) {
      updateState((state) => state.copyWith(
            message: 'Error al cargar mensajes: $e',
          ));
    }
  }

  /// Limpia el chat.
  void _handleClearChat() {
    updateState((state) => state.copyWith(
          messages: [],
          currentText: '',
          message: null,
        ));
  }

  /// Marca mensajes como leídos.
  void _handleMarkMessagesAsRead() {
    final updatedMessages = state.messages.map((message) {
      if (message.receiverId == _currentUserId &&
          message.status != MessageStatus.read) {
        return message.copyWith(status: MessageStatus.read);
      }
      return message;
    }).toList();

    updateState((state) => state.copyWith(messages: updatedMessages));
  }

  /// Actualiza el estado de "está escribiendo".
  void _handleUpdateTypingStatus(UpdateTypingStatus action) {
    updateState((state) => state.copyWith(isTyping: action.isTyping));
  }
}
