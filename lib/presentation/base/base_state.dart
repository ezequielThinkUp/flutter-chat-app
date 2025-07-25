import 'package:chat/presentation/base/base_status.dart';

/// Clase base para todos los estados de flujos de presentación.
///
/// Proporciona propiedades comunes para manejo de estado,
/// mensajes y estado de carga/error.
abstract class BaseState {
  /// Estado actual del flujo.
  final BaseStatus status;

  /// Mensaje asociado al estado (útil para errores o información).
  final String? message;

  const BaseState({
    this.status = BaseStatus.initial,
    this.message,
  });

  /// Método que debe ser implementado por las clases hijas
  /// para crear copias del estado con nuevos valores.
  BaseState copyWith({
    BaseStatus? status,
    String? message,
  });

  /// Conveniencia para obtener estados comunes.
  BaseState get loading => copyWith(status: BaseStatus.loading);
  BaseState get success => copyWith(status: BaseStatus.success);
  BaseState error(String message) => copyWith(
        status: BaseStatus.error,
        message: message,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseState &&
        other.status == status &&
        other.message == message;
  }

  @override
  int get hashCode => status.hashCode ^ message.hashCode;
}
