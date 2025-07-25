import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/presentation/core/base_hook_widget.dart';
import 'package:chat/domain/entities/user.dart';

/// Item de lista para mostrar información de un usuario.
///
/// Widget enfocado que muestra avatar, nombre, email y estado online.
class UserListItem extends BaseHookWidget {
  /// Usuario a mostrar.
  final User user;

  /// Callback cuando se toca el item.
  final VoidCallback? onTap;

  const UserListItem({
    super.key,
    required this.user,
    this.onTap,
  });

  @override
  Widget buildView(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: _getAvatarColor(),
        child: Text(
          _getInitials(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        user.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        user.email,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: user.isOnline ? Colors.green : Colors.grey,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }

  /// Obtiene las iniciales del nombre del usuario.
  String _getInitials() {
    final names = user.name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return user.name.length >= 2
        ? user.name.substring(0, 2).toUpperCase()
        : user.name[0].toUpperCase();
  }

  /// Obtiene un color de avatar basado en el nombre.
  Color _getAvatarColor() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.red,
    ];

    final hash = user.name.hashCode;
    return colors[hash.abs() % colors.length];
  }
}
