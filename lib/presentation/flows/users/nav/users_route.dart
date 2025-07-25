import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chat/presentation/flows/users/ui/users_screen.dart';

/// Configuración de rutas para el flujo de usuarios.
class UsersRouter {
  static const String usersRouteName = 'users';
  static const String usersPath = '/users';

  static GoRoute getRoute() {
    return GoRoute(
      name: usersRouteName,
      path: usersPath,
      builder: (context, state) => const UsersScreen(),
    );
  }

  /// Métodos de navegación de conveniencia.
  static void navigateToUsers(BuildContext context) {
    context.goNamed(usersRouteName);
  }

  static void replaceWithUsers(BuildContext context) {
    context.pushReplacementNamed(usersRouteName);
  }
}
