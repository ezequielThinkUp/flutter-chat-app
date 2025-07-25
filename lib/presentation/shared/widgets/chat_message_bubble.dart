import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/presentation/core/base_hook_widget.dart';

/// Burbuja de mensaje de chat reutilizable.
///
/// Widget enfocado que muestra un mensaje con diferentes estilos
/// según si es del usuario actual o de otro usuario.
class ChatMessageBubble extends BaseHookWidget {
  /// Texto del mensaje.
  final String text;

  /// ID del usuario que envió el mensaje.
  final String userId;

  /// ID del usuario actual (para determinar el estilo).
  final String currentUserId;

  /// Timestamp del mensaje (opcional).
  final DateTime? timestamp;

  /// Nombre del usuario (para mensajes de otros).
  final String? userName;

  /// Indica si debe mostrar animación de entrada.
  final bool animate;

  const ChatMessageBubble({
    super.key,
    required this.text,
    required this.userId,
    required this.currentUserId,
    this.timestamp,
    this.userName,
    this.animate = true,
  });

  /// Indica si el mensaje es del usuario actual.
  bool get isMyMessage => userId == currentUserId;

  @override
  Widget buildView(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: isMyMessage ? _buildMyMessage() : _buildOtherMessage(),
    );
  }

  /// Construye la burbuja para mensajes propios.
  Widget _buildMyMessage() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(left: 50),
        decoration: BoxDecoration(
          color: const Color(0xff4D9EF6),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            if (timestamp != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatTime(timestamp!),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Construye la burbuja para mensajes de otros usuarios.
  Widget _buildOtherMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(right: 50),
        decoration: BoxDecoration(
          color: const Color(0xffE4E5E8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (userName != null) ...[
              Text(
                userName!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
            if (timestamp != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatTime(timestamp!),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Formatea la hora del mensaje.
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
