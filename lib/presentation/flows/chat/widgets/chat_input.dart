import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/presentation/core/base_hook_widget.dart';
import 'package:chat/presentation/flows/chat/providers/chat_provider.dart';

/// Widget de input para enviar mensajes en el chat.
///
/// Maneja el texto del mensaje, estado de escritura y envío de mensajes
/// con diferencias de UI entre iOS y Android.
class ChatInput extends BaseHookWidget {
  const ChatInput({super.key});

  @override
  Widget buildView(BuildContext context, WidgetRef ref) {
    final state = ref.chatState;
    final textController = useTextEditingController();
    final focusNode = useFocusNode();

    // Sincronizar el controller con el estado
    useEffect(() {
      if (textController.text != state.currentText) {
        textController.text = state.currentText;
      }
      return null;
    }, [state.currentText]);

    // Auto-focus al inicializar
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        focusNode.requestFocus();
      });
      return null;
    }, []);

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              // Campo de texto
              Expanded(
                child: TextField(
                  controller: textController,
                  focusNode: focusNode,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Enviar mensaje',
                  ),
                  onChanged: (text) {
                    ref.updateMessageText(text);
                  },
                  onSubmitted: (text) {
                    _handleSubmit(ref, text, focusNode);
                  },
                ),
              ),
              // Botón de envío
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _buildSendButton(
                    context, ref, state, textController, focusNode),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el botón de envío apropiado para cada plataforma.
  Widget _buildSendButton(
    BuildContext context,
    WidgetRef ref,
    dynamic state,
    TextEditingController controller,
    FocusNode focusNode,
  ) {
    final canSend = state.canSendMessage && !state.isSendingMessage;

    if (Platform.isIOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: canSend
            ? () => _handleSubmit(ref, controller.text, focusNode)
            : null,
        child: Text(
          'Enviar',
          style: TextStyle(
            color: canSend
                ? CupertinoColors.activeBlue
                : CupertinoColors.inactiveGray,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return IconTheme(
      data: IconThemeData(
        color: canSend ? Colors.blue[400] : Colors.grey,
      ),
      child: IconButton(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        icon: state.isSendingMessage
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.send),
        onPressed: canSend
            ? () => _handleSubmit(ref, controller.text, focusNode)
            : null,
      ),
    );
  }

  /// Maneja el envío del mensaje.
  void _handleSubmit(WidgetRef ref, String text, FocusNode focusNode) {
    if (text.trim().isEmpty) return;

    // Enviar mensaje
    ref.sendMessage(text);

    // Mantener el focus para continuar escribiendo
    focusNode.requestFocus();
  }
}
