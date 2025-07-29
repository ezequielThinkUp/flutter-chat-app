import 'dart:io';

/// Configuración de entorno para la aplicación.
class Environment {
  /// URL base de la API
  /// URL del servidor Socket.IO según la plataforma.
  static String get apiUrl {
    if (Platform.isAndroid) {
      // Detectar si es emulador o dispositivo físico
      return _isAndroidEmulator()
          ? 'http://10.0.2.2:3000' // Emulador Android
          : 'http://192.168.181.75:3000'; // Dispositivo físico Android
    } else if (Platform.isIOS) {
      // Detectar si es simulador o dispositivo físico
      return _isIOSSimulator()
          ? 'http://localhost:3000' // Simulador iOS
          : 'http://192.168.181.75:3000'; // Dispositivo físico iOS
    } else {
      // Otras plataformas (Web, Desktop)
      return 'http://localhost:3000';
    }
  }

  /// URL del servidor Socket.IO según la plataforma.
  static String get socketUrl {
    if (Platform.isAndroid) {
      // Detectar si es emulador o dispositivo físico
      return _isAndroidEmulator()
          ? 'http://10.0.2.2:3000' // Emulador Android
          : 'http://192.168.181.75:3000'; // Dispositivo físico Android
    } else if (Platform.isIOS) {
      // Detectar si es simulador o dispositivo físico
      return _isIOSSimulator()
          ? 'http://localhost:3000' // Simulador iOS
          : 'http://192.168.181.75:3000'; // Dispositivo físico iOS
    } else {
      // Otras plataformas (Web, Desktop)
      return 'http://localhost:3000';
    }
  }

  /// Indica si estamos en modo desarrollo.
  static const bool isDevelopment = true;

  /// Timeout por defecto para peticiones HTTP.
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Configuraciones adicionales
  static const String appName = 'Chat App';
  static const String appVersion = '1.0.0';

  /// Configuración de red - Cambia según tu entorno
  /// true = usar IP local (dispositivos físicos)
  /// false = usar localhost/10.0.2.2 (emuladores/simuladores)
  static const bool useLocalNetwork = true;

  /// Detecta si está ejecutándose en un emulador de Android.
  static bool _isAndroidEmulator() {
    // Si useLocalNetwork es true, asumimos dispositivo físico
    // Si es false, asumimos emulador
    return !useLocalNetwork;
  }

  /// Detecta si está ejecutándose en un simulador de iOS.
  static bool _isIOSSimulator() {
    // Si useLocalNetwork es true, asumimos dispositivo físico
    // Si es false, asumimos simulador
    return !useLocalNetwork;
  }
}
