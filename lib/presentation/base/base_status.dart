/// Estados base para el manejo de flujos de presentación.
///
/// Permite manejar de forma consistente los diferentes estados
/// por los que puede pasar un flujo (inicial, cargando, éxito, error).
enum BaseStatus {
  /// Estado inicial del flujo.
  initial,

  /// Estado de carga activa.
  loading,

  /// Estado de éxito tras completar una operación.
  success,

  /// Estado de error tras fallar una operación.
  error,
}

/// Extensiones útiles para BaseStatus.
extension BaseStatusX on BaseStatus {
  /// Indica si el estado es de carga.
  bool get isLoading => this == BaseStatus.loading;

  /// Indica si el estado es de éxito.
  bool get isSuccess => this == BaseStatus.success;

  /// Indica si el estado es de error.
  bool get isError => this == BaseStatus.error;

  /// Indica si el estado es inicial.
  bool get isInitial => this == BaseStatus.initial;
}
