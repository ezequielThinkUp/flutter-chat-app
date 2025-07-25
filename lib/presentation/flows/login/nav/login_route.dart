import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chat/presentation/flows/login/ui/login_screen.dart';

/// Configuración de rutas para el flujo de login.
class LoginRouter {
  static const String loginRouteName = 'login';
  static const String loginPath = '/login';

  static GoRoute getRoute() {
    return GoRoute(
      name: loginRouteName,
      path: loginPath,
      builder: (context, state) => const LoginScreen(),
    );
  }

  /// Métodos de navegación de conveniencia.
  static void navigateToLogin(BuildContext context) {
    context.goNamed(loginRouteName);
  }

  static void replaceWithLogin(BuildContext context) {
    context.pushReplacementNamed(loginRouteName);
  }
}
