import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/domain/datasources/auth_datasource.dart';
import 'package:chat/infrastructure/datasources/auth_remote_datasource.dart';
import 'package:chat/infrastructure/services/auth_service.dart';

/// Provider para el DataSource de autenticación.
///
/// Configuración de DI para AuthDataSource.
/// Ubicado en infrastructure/providers/datasources/ para separar
/// la configuración de DI de las implementaciones.
final authDataSourceProvider = Provider<AuthDataSource>(
  (ref) {
    final authService = ref.watch(authServiceProvider);
    return AuthRemoteDataSource(authService);
  },
);
