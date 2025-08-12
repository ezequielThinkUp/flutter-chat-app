import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/presentation/base/base_stateful_widget.dart';
import 'package:chat/presentation/base/content_state/content_state_widget.dart';
import 'package:chat/presentation/flows/login/providers/login_provider.dart';
import 'package:chat/presentation/flows/login/states/action.dart';
import 'package:chat/presentation/flows/login/widgets/login_form.dart';
import 'package:chat/presentation/flows/login/widgets/login_header.dart';
import 'package:chat/routes/app_router.dart';

/// Pantalla de login siguiendo la arquitectura de flows.
///
/// Extiende ConsumerStatefulWidget y usa BaseStatefulWidget
/// para suscripciones automáticas a navegación y alertas.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends BaseStatefulWidget<LoginScreen> {
  @override
  Widget buildView(BuildContext context) {
    final state = ref.loginState;

    // Escuchar cambios de estado para navegación
    ref.listen(loginProvider.provider, (previous, next) {
      if ((next.message ?? '') == 'Login exitoso' &&
          (previous?.message ?? '') != (next.message ?? '')) {
        // Navegar a usuarios tras login exitoso
        context.goToUsers();
      }

      // Manejar errores de conexión
      if (next.shouldRedirectToLogin && !previous!.shouldRedirectToLogin) {
        // Mostrar diálogo de error de conexión
        _showConnectionErrorDialog(
            context, next.message ?? 'Error de conexión');
      }

      // Manejar errores de autenticación (no de conexión)
      if (next.message != null &&
          next.message!.contains('Error') &&
          !next.shouldRedirectToLogin &&
          (previous?.message ?? '') != next.message) {
        // Mostrar alert de error de autenticación
        _showAuthErrorAlert(context, next.message!);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      // FAB para acceso rápido a Socket test (solo en desarrollo)
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        tooltip: 'Probar Socket.IO',
        onPressed: () => context.goToSocketTest(),
        child: const Icon(Icons.wifi_tethering),
      ),
      body: ContentStateWidget(
        isLoading: state.isLoading,
        // No mostrar error aquí porque lo manejamos con diálogo personalizado
        errorMessage: null,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AuthHeader(title: 'Login'),
                  LoginForm(),
                  _LoginFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void onInitState() {
    super.onInitState();

    // Usar WidgetsBinding para ejecutar después del build cycle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.executeLoginAction(const ClearForm());
      }
    });
  }

  /// Muestra un diálogo de error de conexión.
  void _showConnectionErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.red),
              SizedBox(width: 8),
              Text('Error de Conexión'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              const SizedBox(height: 16),
              const Text(
                'Verifica:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Tu conexión a internet'),
              const Text('• Que el servidor esté funcionando'),
              const Text('• Intenta nuevamente'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Limpiar el estado de error y redirigir al login
                ref.executeLoginAction(const ClearForm());
                // Redirigir al login usando GoRouter
                context.goToLogin();
              },
              child: const Text('Entendido'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Intentar login nuevamente
                ref.executeLoginAction(const SubmitLogin());
              },
              child: const Text('Reintentar'),
            ),
          ],
        );
      },
    );
  }

  /// Muestra un alert de error de autenticación.
  void _showAuthErrorAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  'Error de Autenticación',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Text(
              message,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Limpiar el estado de error
                ref.executeLoginAction(const ClearForm());
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

/// Footer de la pantalla de login.
class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 50),
      child: TextButton(
        onPressed: () => context.goToRegister(),
        child: const Text(
          '¿No tienes cuenta? Crear una cuenta nueva',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
