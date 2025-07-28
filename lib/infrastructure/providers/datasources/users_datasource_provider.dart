import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/infrastructure/datasources/users_datasource.dart';
import 'package:chat/infrastructure/datasources/users_remote_datasource.dart';
import 'package:chat/infrastructure/services/auth_service.dart';

/// Provider para el DataSource de usuarios.
///
/// Configuración de DI para UsersDataSource.
/// Ubicado en infrastructure/providers/datasources/ para separar
/// la configuración de DI de las implementaciones.
final usersDataSourceProvider = Provider<UsersDataSource>(
  (ref) {
    final authService = ref.watch(authServiceWithAuthProvider);
    return UsersRemoteDataSource(authService);
  },
);
