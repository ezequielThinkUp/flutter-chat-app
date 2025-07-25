import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chat/presentation/flows/socket_test/socket_test_screen.dart';

/// Configuración de rutas para el flujo de prueba de Socket.IO.
class SocketTestRouter {
  static const String socketTestRouteName = 'socket_test';
  static const String socketTestPath = '/socket-test';

  static GoRoute getRoute() {
    return GoRoute(
      name: socketTestRouteName,
      path: socketTestPath,
      builder: (context, state) => const SocketTestScreen(),
    );
  }

  /// Métodos de navegación de conveniencia.
  static void navigateToSocketTest(BuildContext context) {
    context.goNamed(socketTestRouteName);
  }

  static void pushSocketTest(BuildContext context) {
    context.pushNamed(socketTestRouteName);
  }
}
