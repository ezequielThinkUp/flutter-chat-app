import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chat/presentation/flows/register/ui/register_screen.dart';

/// Configuración de rutas para el flujo de registro.
class RegisterRouter {
  static const String registerRouteName = 'register';
  static const String registerPath = '/register';

  static GoRoute getRoute() {
    return GoRoute(
      name: registerRouteName,
      path: registerPath,
      builder: (context, state) => const RegisterScreen(),
    );
  }

  /// Métodos de navegación de conveniencia.
  static void navigateToRegister(BuildContext context) {
    context.goNamed(registerRouteName);
  }

  static void replaceWithRegister(BuildContext context) {
    context.pushReplacementNamed(registerRouteName);
  }
}
