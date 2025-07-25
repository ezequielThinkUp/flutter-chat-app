// Removed unused import
import 'package:chat/domain/entities/auth_result.dart';
import 'package:chat/domain/entities/user.dart';
import 'package:chat/domain/repositories/auth_repository.dart';
import 'package:chat/domain/datasources/auth_datasource.dart';
import 'package:chat/infrastructure/storage/secure_storage.dart';
import 'package:chat/infrastructure/utils/jwt_utils.dart';

/// Implementación del repositorio de autenticación.
///
/// Coordina las operaciones entre el DataSource y las entidades de dominio.
/// Maneja tokens en memoria y almacenamiento seguro.
/// Siguiendo principios de Clean Architecture: Repository → DataSource → API
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _authDataSource;
  final SecureStorage _secureStorage;

  // Token en memoria para acceso rápido
  String? _cachedToken;
  User? _cachedUser;

  AuthRepositoryImpl(this._authDataSource, this._secureStorage);

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🏛️ AuthRepository: Iniciando login...');

      // Usar DataSource en lugar de servicio directo
      final response = await _authDataSource.login({
        'email': email,
        'password': password,
      });

      final authResult = response.toDomain();

      // Guardar token y usuario en memoria
      _cachedToken = authResult.token;
      _cachedUser = authResult.user;

      // Guardar en secure storage
      await _secureStorage.saveSession(
        token: authResult.token,
        userData: authResult.user.toJson(),
        expiresAt: authResult.expiresAt,
      );

      print('✅ AuthRepository: Login exitoso y sesión guardada');
      return authResult;
    } catch (e) {
      print('❌ AuthRepository: Error en login: $e');
      // Los errores ya vienen procesados del DataSource
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      print('🚪 Iniciando proceso de logout...');

      // Intentar logout en el servidor (si falla no importa)
      try {
        await _authDataSource.logout();
        print('✅ Logout del servidor exitoso');
      } catch (e) {
        print('⚠️ Error en logout del servidor (continuando): $e');
      }

      // Limpiar memoria
      _cachedToken = null;
      _cachedUser = null;
      print('🧹 Memoria limpiada');

      // Limpiar secure storage
      await _secureStorage.clearAuthData();
      print('🔐 Storage seguro limpiado');

      // Verificar que la limpieza fue completa
      final hasStoredSession = await _secureStorage.hasStoredSession();
      if (hasStoredSession) {
        print('⚠️ Advertencia: Aún hay datos en storage, forzando limpieza...');
        await _secureStorage.clearAuthData(); // Segundo intento
      }

      print('✅ Logout completado y sesión limpiada');
    } catch (e) {
      print('❌ Error limpiando sesión en logout: $e');
      // Forzar limpieza de memoria aunque falle el storage
      _cachedToken = null;
      _cachedUser = null;

      // Re-lanzar el error para que el notifier pueda manejarlo
      rethrow;
    }
  }

  @override
  Future<AuthResult> refreshToken() async {
    try {
      // TODO: Obtener token actual del storage
      // final currentToken = await _tokenStorage.getToken();
      // if (currentToken == null) {
      //   throw Exception('No hay token para renovar');
      // }

      final refreshTokenValue = await _secureStorage.getRefreshToken();
      if (refreshTokenValue == null) {
        throw Exception('No hay refresh token disponible');
      }

      final response = await _authDataSource.refreshToken({
        'refresh_token': refreshTokenValue,
      });

      final authResult = response.toDomain();

      // Actualizar token y usuario en memoria
      _cachedToken = authResult.token;
      _cachedUser = authResult.user;

      // Actualizar en secure storage
      await _secureStorage.saveSession(
        token: authResult.token,
        userData: authResult.user.toJson(),
        expiresAt: authResult.expiresAt,
      );

      print('✅ AuthRepository: Token renovado exitosamente');
      return authResult;
    } catch (e) {
      print('❌ AuthRepository: Error renovando token: $e');
      // Los errores ya vienen procesados del DataSource
      rethrow;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      // Primero intentar desde memoria
      if (_cachedUser != null) {
        return _cachedUser;
      }

      // Si no está en memoria, cargar desde storage
      final sessionData = await _secureStorage.getSession();
      if (sessionData?.userData != null) {
        _cachedUser = User.fromJson(sessionData!.userData!);
        return _cachedUser;
      }

      return null;
    } catch (e) {
      print('❌ Error obteniendo usuario actual: $e');
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await getCurrentToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      // Verificar si el token no está expirado
      return !JwtUtils.isTokenExpired(token);
    } catch (e) {
      print('❌ Error verificando sesión activa: $e');
      return false;
    }
  }

  @override
  Future<String?> getCurrentToken() async {
    try {
      // Primero intentar desde memoria (más rápido)
      if (_cachedToken != null && !JwtUtils.isTokenExpired(_cachedToken!)) {
        return _cachedToken;
      }

      // Si no está en memoria o está expirado, cargar desde storage
      final token = await _secureStorage.getToken();
      if (token != null && !JwtUtils.isTokenExpired(token)) {
        _cachedToken = token;
        return token;
      }

      // Token expirado o no existe
      _cachedToken = null;
      return null;
    } catch (e) {
      print('❌ Error obteniendo token actual: $e');
      return null;
    }
  }

  @override
  Future<void> initializeAuth() async {
    try {
      print('🚀 Inicializando autenticación...');

      // Cargar sesión desde storage
      final sessionData = await _secureStorage.getSession();
      if (sessionData == null) {
        print('ℹ️ No hay sesión guardada');
        return;
      }

      // Verificar si el token es válido
      if (JwtUtils.isTokenExpired(sessionData.token)) {
        print('⚠️ Token expirado al inicializar, limpiando sesión');
        await _secureStorage.clearAuthData();
        return;
      }

      // Cargar en memoria
      _cachedToken = sessionData.token;
      if (sessionData.userData != null) {
        _cachedUser = User.fromJson(sessionData.userData!);
      }

      print('✅ Sesión restaurada exitosamente: ${_cachedUser?.name}');
    } catch (e) {
      print('❌ Error inicializando autenticación: $e');
      // Limpiar cualquier dato corrupto
      await _secureStorage.clearAuthData();
    }
  }
}
