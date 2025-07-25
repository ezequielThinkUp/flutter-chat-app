import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/presentation/flows/chat/providers/chat_provider.dart';
import 'package:chat/presentation/shared/widgets/chat_message_bubble.dart';
import 'package:chat/presentation/core/base_hook_widget.dart';

/// Lista de mensajes del chat.
///
/// Widget que muestra todos los mensajes del chat en orden cronológico
/// (más recientes primero) con scroll automático y animaciones.
class ChatMessagesList extends BaseHookWidget {
  const ChatMessagesList({super.key});

  @override
  Widget buildView(BuildContext context, WidgetRef ref) {
    final state = ref.chatState;
    final currentUserId = '123'; // TODO: Obtener del contexto de autenticación

    // Si no hay mensajes, mostrar estado vacío
    if (!state.hasMessages) {
      return const _EmptyMessagesState();
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      reverse: true, // Mensajes más recientes al final
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ChatMessageBubble(
            text: message.content,
            userId: message.senderId,
            currentUserId: currentUserId,
            timestamp: message.timestamp,
          ),
        );
      },
    );
  }
}

/// Estado vacío cuando no hay mensajes.
class _EmptyMessagesState extends StatelessWidget {
  const _EmptyMessagesState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No hay mensajes aún',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Envía el primer mensaje para comenzar la conversación',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
