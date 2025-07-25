import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/presentation/base/base_screen.dart';

/// Widget base para todas las pantallas de flujos de presentación.
///
/// Extiende ConsumerState y mezcla BaseScreen para proporcionar:
/// - Suscripciones automáticas a navegación y alertas
/// - Método buildView que debe ser implementado por las pantallas
/// - Manejo consistente del ciclo de vida
///
/// Ejemplo de uso:
/// ```dart
/// class LoginScreen extends ConsumerStatefulWidget {
///   const LoginScreen({super.key});
///
///   @override
///   ConsumerState<LoginScreen> createState() => _LoginScreenState();
/// }
///
/// class _LoginScreenState extends BaseStatefulWidget<LoginScreen> {
///   @override
///   Widget buildView(BuildContext context) {
///     final state = ref.watch(loginProvider);
///     return ContentStateWidget(
///       state: state,
///       child: LoginForm(),
///     );
///   }
/// }
/// ```
abstract class BaseStatefulWidget<T extends ConsumerStatefulWidget>
    extends ConsumerState<T> with BaseScreen {
  /// Método abstracto que debe ser implementado por las pantallas.
  ///
  /// Reemplaza al build tradicional y debe contener la UI específica
  /// de la pantalla. El primer widget debe ser ContentStateWidget.
  Widget buildView(BuildContext context);

  @override
  Widget build(BuildContext context) {
    // Configurar suscripciones automáticas
    subscribeAlert(ref: ref);
    subscribeNavigation(
      ref: ref,
      context: context,
    );

    // Retornar la vista construida por la pantalla
    return buildView(context);
  }

  @override
  void initState() {
    super.initState();
    onInitState();
  }

  @override
  void dispose() {
    onDispose();
    super.dispose();
  }

  /// Método que puede ser sobrescrito para lógica de inicialización.
  void onInitState() {
    // Implementación opcional en las pantallas hijas
  }

  /// Método que puede ser sobrescrito para lógica de limpieza.
  void onDispose() {
    // Implementación opcional en las pantallas hijas
  }
}
