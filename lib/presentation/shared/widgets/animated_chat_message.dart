import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/presentation/core/base_hook_widget.dart';
import 'package:chat/presentation/shared/widgets/chat_message_bubble.dart';

/// Wrapper animado para mensajes de chat.
///
/// Proporciona animaciones de entrada suaves para los mensajes
/// manteniendo el widget de burbuja enfocado en su responsabilidad.
class AnimatedChatMessage extends BaseHookWidget {
  /// El mensaje a mostrar.
  final ChatMessageBubble message;

  /// Controlador de animación.
  final AnimationController animationController;

  const AnimatedChatMessage({
    super.key,
    required this.message,
    required this.animationController,
  });

  @override
  Widget buildView(BuildContext context, WidgetRef ref) {
    return FadeTransition(
      opacity: animationController,
      child: SizeTransition(
        sizeFactor: CurvedAnimation(
          parent: animationController,
          curve: Curves.easeOut,
        ),
        child: message,
      ),
    );
  }
}
