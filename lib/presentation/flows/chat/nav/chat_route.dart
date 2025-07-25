import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chat/presentation/flows/chat/ui/chat_screen.dart';

/// Configuración de rutas para el flujo de chat.
class ChatRouter {
  static const String chatRouteName = 'chat';
  static const String chatPath = '/chat/:recipientUserId';

  static GoRoute getRoute() {
    return GoRoute(
      name: chatRouteName,
      path: chatPath,
      builder: (context, state) {
        final recipientUserId = state.pathParameters['recipientUserId']!;
        final recipientUserName =
            state.uri.queryParameters['recipientUserName'] ?? 'Usuario';
        final recipientAvatar = state.uri.queryParameters['recipientAvatar'];

        return ChatScreen(
          recipientUserId: recipientUserId,
          recipientUserName: recipientUserName,
          recipientAvatar: recipientAvatar,
        );
      },
    );
  }

  /// Métodos de navegación de conveniencia.
  static void navigateToChat(
    BuildContext context, {
    required String recipientUserId,
    required String recipientUserName,
    String? recipientAvatar,
  }) {
    context.goNamed(
      chatRouteName,
      pathParameters: {'recipientUserId': recipientUserId},
      queryParameters: {
        'recipientUserName': recipientUserName,
        if (recipientAvatar != null) 'recipientAvatar': recipientAvatar,
      },
    );
  }
}
