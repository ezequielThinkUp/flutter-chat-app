import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chat/presentation/flows/login/nav/login_route.dart';
import 'package:chat/presentation/flows/register/nav/register_route.dart';
import 'package:chat/presentation/flows/users/nav/users_route.dart';
import 'package:chat/presentation/flows/chat/nav/chat_route.dart';
import 'package:chat/presentation/flows/socket_test/nav/socket_test_route.dart';

/// Configuración moderna de rutas usando go_router.
///
/// Proporciona navegación declarativa con type safety y parámetros dinámicos.
final GoRouter appRouter = GoRouter(
  initialLocation: LoginRouter.loginPath,
  routes: [
    // Rutas usando los routers individuales
    LoginRouter.getRoute(),
    RegisterRouter.getRoute(),
    UsersRouter.getRoute(),
    ChatRouter.getRoute(),
    SocketTestRouter.getRoute(),
  ],

  // Manejo de errores de navegación
  errorPageBuilder: (context, state) => MaterialPage<void>(
    key: state.pageKey,
    child: Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Ruta: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.goNamed(LoginRouter.loginRouteName),
              child: const Text('Ir al Login'),
            ),
          ],
        ),
      ),
    ),
  ),
);

/// Nombres de rutas de la aplicación - mantenido para compatibilidad.
///
/// Centraliza todos los nombres de rutas para evitar errores de tipeo
/// y facilitar refactoring.
abstract class AppRoutes {
  static const String login = LoginRouter.loginRouteName;
  static const String register = RegisterRouter.registerRouteName;
  static const String users = UsersRouter.usersRouteName;
  static const String chat = ChatRouter.chatRouteName;
  static const String socketTest = SocketTestRouter.socketTestRouteName;
}

/// Extensiones de conveniencia para navegación.
extension AppNavigationX on BuildContext {
  /// Navega al login.
  void goToLogin() => goNamed(LoginRouter.loginRouteName);

  /// Navega al registro.
  void goToRegister() => goNamed(RegisterRouter.registerRouteName);

  /// Navega a la lista de usuarios.
  void goToUsers() => goNamed(UsersRouter.usersRouteName);

  /// Navega al chat con un usuario específico.
  void goToChat({
    required String recipientUserId,
    required String recipientUserName,
    String? recipientAvatar,
  }) {
    ChatRouter.navigateToChat(
      this,
      recipientUserId: recipientUserId,
      recipientUserName: recipientUserName,
      recipientAvatar: recipientAvatar,
    );
  }

  /// Reemplaza la pantalla actual con login.
  void replaceWithLogin() => pushReplacementNamed(LoginRouter.loginRouteName);

  /// Reemplaza la pantalla actual con usuarios.
  void replaceWithUsers() => pushReplacementNamed(UsersRouter.usersRouteName);

  /// Navega a la pantalla de prueba de Socket.IO.
  void goToSocketTest() => goNamed(SocketTestRouter.socketTestRouteName);

  /// Abre la pantalla de prueba de Socket.IO como modal.
  void pushSocketTest() => pushNamed(SocketTestRouter.socketTestRouteName);
}
