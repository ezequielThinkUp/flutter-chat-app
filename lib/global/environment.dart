import 'dart:io';

/// Configuración de entorno para la aplicación.
class Environment {
  /// URL base de la API según la plataforma.
  static String get apiUrl {
    if (Platform.isAndroid) {
      // Android Emulator: 10.0.2.2 mapea a localhost de la máquina host
      return 'http://10.0.2.2:3000/api';
    } else if (Platform.isIOS) {
      // iOS Simulator: localhost funciona directamente
      return 'http://localhost:3000/api';
    } else {
      // Otras plataformas (Web, Desktop)
      return 'http://localhost:3000/api';
    }
  }

  /// Indica si estamos en modo desarrollo.
  static const bool isDevelopment = true;

  /// Timeout por defecto para peticiones HTTP.
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Configuraciones adicionales
  static const String appName = 'Chat App';
  static const String appVersion = '1.0.0';
}
