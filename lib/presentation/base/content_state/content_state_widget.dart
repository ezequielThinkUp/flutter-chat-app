import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chat/presentation/shared/widgets/loading_indicator.dart';

/// Widget que maneja automáticamente la visualización según el estado.
///
/// Este widget debe ser el primero dentro de cada pantalla de flujo
/// y se encarga de mostrar:
/// - Loading cuando isLoading es true
/// - Error cuando errorMessage no es null
/// - El contenido normal en otros casos
///
/// Ejemplo de uso:
/// ```dart
/// @override
/// Widget buildView(BuildContext context) {
///   final state = ref.watch(loginProvider.provider);
///   return ContentStateWidget(
///     isLoading: state.isLoading,
///     errorMessage: state.message,
///     child: LoginForm(),
///   );
/// }
/// ```
class ContentStateWidget extends StatelessWidget {
  /// Widget hijo que se mostrará cuando el estado permita mostrar contenido.
  final Widget child;

  /// Si está en estado de carga.
  final bool isLoading;

  /// Mensaje de error (null si no hay error).
  final String? errorMessage;

  /// Widget personalizado para mostrar durante loading.
  final Widget? loadingWidget;

  /// Widget personalizado para mostrar durante error.
  final Widget Function(String message)? errorBuilder;

  /// Si debe mostrar el contenido incluso durante loading.
  final bool showContentWhileLoading;

  const ContentStateWidget({
    super.key,
    required this.child,
    this.isLoading = false,
    this.errorMessage,
    this.loadingWidget,
    this.errorBuilder,
    this.showContentWhileLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Mostrar error primero (prioridad sobre loading)
    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: errorBuilder?.call(errorMessage!) ??
              _DefaultErrorWidget(
                message: errorMessage!,
              ),
        ),
      );
    }

    // Mostrar loading
    if (isLoading) {
      if (showContentWhileLoading) {
        return Stack(
          children: [
            child,
            Container(
              color: Colors.black26,
              child: Center(
                child: loadingWidget ??
                    const LoadingIndicator(
                      message: 'Cargando...',
                    ),
              ),
            ),
          ],
        );
      } else {
        return Scaffold(
          body: Center(
            child: loadingWidget ??
                const LoadingIndicator(
                  message: 'Cargando...',
                ),
          ),
        );
      }
    }

    // Mostrar contenido normal
    return child;
  }
}

/// Widget por defecto para mostrar errores.
class _DefaultErrorWidget extends StatelessWidget {
  final String message;

  const _DefaultErrorWidget({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Algo salió mal',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implementar retry o volver atrás
              context.pop();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Intentar de nuevo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
