import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/presentation/base/base_stateful_widget.dart';
import 'package:chat/presentation/base/content_state/content_state_widget.dart';
import 'package:chat/presentation/flows/chat/providers/chat_provider.dart';
import 'package:chat/presentation/flows/chat/widgets/chat_app_bar.dart';
import 'package:chat/presentation/flows/chat/widgets/chat_messages_list.dart';
import 'package:chat/presentation/flows/chat/widgets/chat_input.dart';

/// Pantalla de chat siguiendo la arquitectura de flows.
///
/// Extiende ConsumerStatefulWidget y usa BaseStatefulWidget
/// para suscripciones automáticas a navegación y alertas.
class ChatScreen extends ConsumerStatefulWidget {
  /// ID del usuario con quien se chatea.
  final String recipientUserId;

  /// Nombre del usuario con quien se chatea.
  final String recipientUserName;

  /// Avatar del usuario (opcional).
  final String? recipientAvatar;

  const ChatScreen({
    super.key,
    required this.recipientUserId,
    required this.recipientUserName,
    this.recipientAvatar,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends BaseStatefulWidget<ChatScreen> {
  @override
  Widget buildView(BuildContext context) {
    final state = ref.chatState;

    return Scaffold(
      appBar: ChatAppBar(
        recipientName: state.displayRecipientName,
        recipientAvatar: state.displayRecipientAvatar,
        isOnline: true, // TODO: Implementar estado de conexión real
      ),
      body: ContentStateWidget(
        isLoading: false, // Chat doesn't show full screen loading
        errorMessage:
            state.message?.contains('Error') == true ? state.message : null,
        showContentWhileLoading: true,
        child: Column(
          children: [
            // Lista de mensajes
            Expanded(
              child: ChatMessagesList(),
            ),
            // Separador
            Divider(height: 1),
            // Input de mensaje
            ChatInput(),
          ],
        ),
      ),
    );
  }

  @override
  void onInitState() {
    super.onInitState();

    // Inicializar el chat con los datos del usuario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.initializeChat(
        recipientUserId: widget.recipientUserId,
        recipientUserName: widget.recipientUserName,
        recipientAvatar: widget.recipientAvatar,
      );
    });
  }

  @override
  void onDispose() {
    // TODO: Limpiar conexión del socket si es necesario
    super.onDispose();
  }
}
