import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/presentation/base/base_state_notifier.dart';
import 'package:chat/presentation/base/base_action.dart';

/// Clase base para providers de flujos de presentación.
///
/// Encapsula la creación y configuración de StateNotifierProvider
/// con funcionalidades adicionales para manejo de acciones.
///
/// Ejemplo de uso:
/// ```dart
/// final loginProvider = BaseProvider<LoginNotifier, LoginState, LoginAction>(
///   (ref) => LoginNotifier(),
/// );
///
/// // En el widget:
/// final state = ref.watch(loginProvider.provider);
/// final notifier = ref.read(loginProvider.provider.notifier);
/// ```
class BaseProvider<N extends BaseStateNotifier<S, A>, S, A extends BaseAction> {
  late final StateNotifierProvider<N, S> _provider;

  /// Constructor que requiere una función para crear el notifier.
  BaseProvider(N Function(Ref ref) create) {
    _provider = StateNotifierProvider<N, S>((ref) => create(ref));
  }

  /// Acceso directo al provider de Riverpod.
  StateNotifierProvider<N, S> get provider => _provider;

  /// Acceso directo al notifier.
  Refreshable<N> get notifier => _provider.notifier;

  /// Método de conveniencia para ejecutar acciones.
  void execute(WidgetRef ref, A action) {
    ref.read(_provider.notifier).execute(action);
  }

  /// Método de conveniencia para leer el estado actual.
  S read(WidgetRef ref) {
    return ref.read(_provider);
  }

  /// Método de conveniencia para escuchar cambios de estado.
  S watch(WidgetRef ref) {
    return ref.watch(_provider);
  }
}
