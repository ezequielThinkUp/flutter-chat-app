import 'package:chat/presentation/base/base_state_notifier.dart';
import 'package:chat/presentation/flows/chat/states/state.dart';
import 'package:chat/presentation/flows/chat/states/action.dart';
import 'package:chat/domain/entities/message.dart';
import 'package:chat/domain/datasources/socket_datasource.dart';
import 'package:chat/domain/datasources/socket_datasource.dart'
    show SocketMessage;
import 'package:chat/domain/repositories/messages_repository.dart';
import 'package:chat/presentation/base/base_status.dart';

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

  /// DataSource para comunicación con socket.
  final SocketDataSource _socketDataSource;

  /// Repositorio para operaciones de mensajes.
  final MessagesRepository _messagesRepository;

  ChatNotifier(this._socketDataSource, this._messagesRepository)
      : super(ChatState.initial()) {
    _setupMessageListener();
  }

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
      case RefreshMessages():
        await _handleLoadMessages();
        break;
      case ClearChat():
        _handleClearChat();
        break;
      case MarkMessagesAsRead():
        _handleMarkMessagesAsRead();
        break;
      case MarkMessageAsRead():
        await _handleMarkMessageAsRead(action);
        break;
      case MarkMessageAsDelivered():
        await _handleMarkMessageAsDelivered(action);
        break;
      case UpdateTypingStatus():
        _handleUpdateTypingStatus(action);
        break;
      case ClearMessage():
        _handleClearMessage();
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

    // Cargar mensajes reales del servidor
    await _handleLoadMessages();
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

      // Enviar mensaje al servidor via socket
      if (state.recipientUserId != null) {
        try {
          await _socketDataSource.sendPrivateMessage(
            recipientUid: state.recipientUserId!,
            message: action.text.trim(),
            type: 'texto',
          );
          print('💬 Mensaje enviado al servidor: ${message.content}');
        } catch (socketError) {
          print('⚠️ Error enviando mensaje al servidor: $socketError');
          // El mensaje ya está en la UI, solo mostrar advertencia
          updateState((state) => state.copyWith(
                message: 'Mensaje enviado localmente (error de conexión)',
              ));
        }
      }

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
      if (state.recipientUserId == null) {
        print('⚠️ No hay recipientUserId para cargar mensajes');
        return;
      }

      print(
          '📥 Cargando mensajes entre usuarios: $_currentUserId y ${state.recipientUserId}');

      // Por ahora, vamos a usar una implementación simple
      // que simula la carga de mensajes reales
      await Future.delayed(const Duration(milliseconds: 300));

      // TODO: Implementar carga real de mensajes desde la API
      // final messages = await _messagesDataSource.getMessagesBetweenUsers(
      //   usuario1: _currentUserId,
      //   usuario2: state.recipientUserId!,
      //   limite: 50,
      // );

      // Por ahora, mantener el chat vacío para que se llenen con mensajes reales
      // que vienen del Socket.IO
      print('✅ Chat inicializado - esperando mensajes en tiempo real');
    } catch (e) {
      print('❌ Error cargando mensajes: $e');
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

  /// Configura el listener para mensajes entrantes del Socket.IO.
  void _setupMessageListener() {
    _socketDataSource.messages.listen((socketMessage) {
      print('📨 Mensaje recibido del socket: ${socketMessage.message}');

      // Verificar si el mensaje es para este chat
      if (state.recipientUserId != null &&
          (socketMessage.from == state.recipientUserId ||
              socketMessage.to == state.recipientUserId)) {
        // Convertir el mensaje del socket a nuestra entidad Message
        final message = Message(
          id: socketMessage.timestamp.toString(),
          content: socketMessage.message,
          senderId: socketMessage.from,
          receiverId: socketMessage.to ?? _currentUserId,
          timestamp: socketMessage.timestamp,
          status: socketMessage.delivered == true
              ? MessageStatus.delivered
              : MessageStatus.sent,
        );

        // Agregar el mensaje a la lista
        final updatedMessages = [...state.messages, message];
        updateState((state) => state.copyWith(messages: updatedMessages));

        print('✅ Mensaje agregado al chat: ${message.content}');
      }
    });
  }

  /// Marca un mensaje específico como leído.
  Future<void> _handleMarkMessageAsRead(MarkMessageAsRead action) async {
    try {
      final success =
          await _messagesRepository.markMessageAsRead(action.messageId);
      if (success) {
        // Actualizar el estado del mensaje en la lista local
        final updatedMessages = state.messages.map((message) {
          if (message.id == action.messageId) {
            return message.copyWith(status: MessageStatus.read);
          }
          return message;
        }).toList();

        updateState((state) => state.copyWith(messages: updatedMessages));
        print('✅ Mensaje marcado como leído: ${action.messageId}');
      }
    } catch (e) {
      print('❌ Error marcando mensaje como leído: $e');
      updateState((state) => state.copyWith(
            status: BaseStatus.error,
            message: 'Error marcando mensaje como leído: $e',
          ));
    }
  }

  /// Marca un mensaje específico como entregado.
  Future<void> _handleMarkMessageAsDelivered(
      MarkMessageAsDelivered action) async {
    try {
      final success =
          await _messagesRepository.markMessageAsDelivered(action.messageId);
      if (success) {
        // Actualizar el estado del mensaje en la lista local
        final updatedMessages = state.messages.map((message) {
          if (message.id == action.messageId) {
            return message.copyWith(status: MessageStatus.delivered);
          }
          return message;
        }).toList();

        updateState((state) => state.copyWith(messages: updatedMessages));
        print('✅ Mensaje marcado como entregado: ${action.messageId}');
      }
    } catch (e) {
      print('❌ Error marcando mensaje como entregado: $e');
      updateState((state) => state.copyWith(
            status: BaseStatus.error,
            message: 'Error marcando mensaje como entregado: $e',
          ));
    }
  }

  /// Limpia el mensaje de error/estado.
  void _handleClearMessage() {
    updateState((state) => state.copyWith(
          status: BaseStatus.initial,
          message: null,
        ));
  }
}
