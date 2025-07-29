import 'package:chat/presentation/base/base_state_notifier.dart';
import 'package:chat/presentation/flows/chat/states/state.dart';
import 'package:chat/presentation/flows/chat/states/action.dart';
import 'package:chat/domain/entities/message.dart';
import 'package:chat/domain/datasources/socket_datasource.dart';
import 'package:chat/domain/usecases/messages/get_messages_between_users_usecase.dart';
import 'package:chat/domain/usecases/messages/mark_message_as_read_usecase.dart';
import 'package:chat/domain/usecases/messages/mark_message_as_delivered_usecase.dart';
import 'package:chat/presentation/base/base_status.dart';
import 'package:chat/domain/repositories/auth_repository.dart'; // Added import for AuthRepository
import 'package:chat/infrastructure/utils/jwt_utils.dart'; // Added import for JwtUtils

/// Notifier del flujo de chat.
///
/// Maneja toda la lógica de negocio relacionada con el chat:
/// - Envío y recepción de mensajes
/// - Estado del input de texto
/// - Gestión de usuarios conectados
/// - Integración con socket para tiempo real
class ChatNotifier extends BaseStateNotifier<ChatState, ChatAction> {
  /// ID del usuario actual (se obtiene dinámicamente).
  String? _currentUserId;

  /// DataSource para comunicación con socket.
  final SocketDataSource _socketDataSource;

  /// Use cases para operaciones de mensajes.
  final GetMessagesBetweenUsersUseCase _getMessagesUseCase;
  final MarkMessageAsReadUseCase _markMessageAsReadUseCase;
  final MarkMessageAsDeliveredUseCase _markMessageAsDeliveredUseCase;

  /// Repository para operaciones de autenticación.
  final AuthRepository _authRepository;

  ChatNotifier(
    this._socketDataSource,
    this._getMessagesUseCase,
    this._markMessageAsReadUseCase,
    this._markMessageAsDeliveredUseCase,
    this._authRepository,
  ) : super(ChatState.initial()) {
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
      // Obtener el ID del usuario actual
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        updateState((state) => state.copyWith(
              message: 'Usuario no autenticado. Por favor, inicie sesión.',
            ));
        return;
      }
      _currentUserId = currentUser.id;

      updateState((state) => state.copyWith(isSendingMessage: true));

      // Crear el mensaje local inmediatamente
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: action.text.trim(),
        senderId: _currentUserId!,
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

      // Obtener el ID del usuario actual
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        print('❌ No hay usuario autenticado');
        updateState((state) => state.copyWith(
              message: 'Usuario no autenticado. Por favor, inicie sesión.',
            ));
        return;
      }
      _currentUserId = currentUser.id;

      print(
          '📥 Cargando mensajes entre usuarios: $_currentUserId y ${state.recipientUserId}');

      // DEBUG: Verificar token antes de hacer la petición
      final token = await _authRepository.getCurrentToken();
      if (token != null) {
        print('🔐 Token disponible: ${token.substring(0, 20)}...');

        // Verificar si el token está expirado
        if (JwtUtils.isTokenExpired(token)) {
          print('⚠️ Token expirado!');
          updateState((state) => state.copyWith(
                message: 'Token expirado. Por favor, inicie sesión nuevamente.',
              ));
          return;
        }

        // Decodificar token para verificar contenido
        final tokenInfo = JwtUtils.decodeToken(token);
        print('🔍 Token info: $tokenInfo');
      } else {
        print('❌ No hay token disponible');
        updateState((state) => state.copyWith(
              message:
                  'No hay token de autenticación disponible. Por favor, inicie sesión.',
            ));
        return;
      }

      // Cargar mensajes reales desde la API usando el use case
      final messages = await _getMessagesUseCase.execute(
        usuario1: _currentUserId!,
        usuario2: state.recipientUserId!,
        limite: 50,
      );

      // Actualizar el estado con los mensajes cargados
      updateState((state) => state.copyWith(messages: messages));

      print('✅ ${messages.length} mensajes cargados del servidor');
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
          receiverId: socketMessage.to ?? _currentUserId!,
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
      final success = await _markMessageAsReadUseCase.execute(action.messageId);
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
          await _markMessageAsDeliveredUseCase.execute(action.messageId);
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
