import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mixin base para todas las pantallas de flujos.
///
/// Proporciona funcionalidades comunes como:
/// - Suscripción a navegación automática
/// - Suscripción a alertas automáticas
/// - Manejo del ciclo de vida de la pantalla
mixin BaseScreen<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// Suscribe la pantalla para recibir alertas automáticamente.
  ///
  /// Las alertas pueden venir desde el notifier del flujo
  /// y se mostrarán como SnackBar, Dialog, etc.
  void subscribeAlert({required WidgetRef ref}) {
    // TODO: Implementar suscripción a alertas
    // Esto requeriría un provider global de alertas
    // ref.listen(alertProvider, (previous, next) {
    //   if (next != null) {
    //     _showAlert(next);
    //   }
    // });
  }

  /// Suscribe la pantalla para recibir eventos de navegación.
  ///
  /// La navegación puede ser disparada desde el notifier
  /// y se ejecutará automáticamente.
  void subscribeNavigation({
    required WidgetRef ref,
    required BuildContext context,
  }) {
    // TODO: Implementar suscripción a navegación
    // Esto requeriría un provider global de navegación
    // ref.listen(navigationProvider, (previous, next) {
    //   if (next != null) {
    //     _navigate(context, next);
    //   }
    // });
  }

  /// Muestra una alerta en la pantalla.
  void showAlert(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Navega a una ruta específica.
  void navigateToRoute(String routeName, {Object? arguments}) {
    if (!mounted) return;

    context.goNamed(routeName);
  }

  /// Reemplaza la ruta actual.
  void navigateAndReplace(String routeName, {Object? arguments}) {
    if (!mounted) return;

    context.goNamed(routeName);
  }

  /// Regresa a la pantalla anterior.
  void navigateBack([Object? result]) {
    if (!mounted) return;

    context.pop(result);
  }
}
