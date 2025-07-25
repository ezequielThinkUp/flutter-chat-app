import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/presentation/base/base_provider.dart';
import 'package:chat/presentation/flows/chat/providers/chat_notifier.dart';
import 'package:chat/presentation/flows/chat/states/state.dart';
import 'package:chat/presentation/flows/chat/states/action.dart';

/// Provider del flujo de chat.
///
/// Utiliza BaseProvider para encapsular la creación y configuración
/// del StateNotifierProvider con funcionalidades adicionales.
final chatProvider = BaseProvider<ChatNotifier, ChatState, ChatAction>(
  (ref) => ChatNotifier(),
);

/// Extension methods para facilitar el uso del provider.
extension ChatProviderX on WidgetRef {
  /// Acceso rápido al estado de chat.
  ChatState get chatState => watch(chatProvider.provider);

  /// Acceso rápido al notifier de chat.
  ChatNotifier get chatNotifier => read(chatProvider.provider.notifier);

  /// Método de conveniencia para ejecutar acciones de chat.
  void executeChatAction(ChatAction action) {
    chatNotifier.execute(action);
  }

  /// Métodos de conveniencia para acciones específicas.
  void initializeChat({
    required String recipientUserId,
    required String recipientUserName,
    String? recipientAvatar,
  }) {
    executeChatAction(InitializeChat(
      recipientUserId: recipientUserId,
      recipientUserName: recipientUserName,
      recipientAvatar: recipientAvatar,
    ));
  }

  void updateMessageText(String text) {
    executeChatAction(UpdateMessageText(text));
  }

  void sendMessage(String text) {
    if (text.trim().isNotEmpty) {
      executeChatAction(SendMessage(text));
    }
  }

  void loadMessages() {
    executeChatAction(const LoadMessages());
  }

  void clearChat() {
    executeChatAction(const ClearChat());
  }

  void markMessagesAsRead() {
    executeChatAction(const MarkMessagesAsRead());
  }

  void updateTypingStatus(bool isTyping) {
    executeChatAction(UpdateTypingStatus(isTyping));
  }
}
