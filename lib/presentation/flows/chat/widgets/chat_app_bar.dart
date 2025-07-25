import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/presentation/core/base_hook_widget.dart';
import 'package:go_router/go_router.dart';

/// AppBar personalizada para el chat.
///
/// Muestra información del receptor como avatar, nombre y estado de conexión.
class ChatAppBar extends BaseHookWidget implements PreferredSizeWidget {
  /// Nombre del usuario receptor.
  final String recipientName;

  /// Avatar del usuario receptor.
  final String recipientAvatar;

  /// Si el usuario está online.
  final bool isOnline;

  const ChatAppBar({
    super.key,
    required this.recipientName,
    required this.recipientAvatar,
    this.isOnline = false,
  });

  @override
  Widget buildView(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => context.pop(),
      ),
      title: Column(
        children: [
          // Avatar del usuario
          CircleAvatar(
            backgroundColor: Colors.blue[100],
            radius: 16,
            child: Text(
              _getInitials(recipientName),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Nombre del usuario
          Text(
            recipientName,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Estado de conexión
          if (isOnline)
            const Text(
              'En línea',
              style: TextStyle(
                color: Colors.green,
                fontSize: 11,
              ),
            ),
        ],
      ),
      actions: [
        // Más opciones
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black87),
          onPressed: () {
            // TODO: Mostrar menú de opciones del chat
            _showChatOptions(context);
          },
        ),
      ],
    );
  }

  /// Obtiene las iniciales del nombre.
  String _getInitials(String name) {
    if (name.isEmpty) return 'U';

    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }

    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'
        .toUpperCase();
  }

  /// Muestra las opciones del chat.
  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Ver perfil'),
              onTap: () {
                context.pop();
                // TODO: Navegar al perfil del usuario
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Limpiar chat'),
              onTap: () {
                context.pop();
                // TODO: Confirmar y limpiar chat
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Bloquear usuario'),
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () {
                context.pop();
                // TODO: Confirmar y bloquear usuario
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
