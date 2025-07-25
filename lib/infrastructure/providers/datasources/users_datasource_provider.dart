import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/domain/datasources/users_datasource.dart';
import 'package:chat/infrastructure/datasources/users_remote_datasource.dart';

/// Provider para el DataSource de usuarios.
///
/// Configuración de DI para UsersDataSource.
/// Ubicado en infrastructure/providers/datasources/ para separar
/// la configuración de DI de las implementaciones.
final usersDataSourceProvider = Provider<UsersDataSource>(
  (ref) {
    // TODO: Inyectar UsersService cuando esté disponible
    return const UsersRemoteDataSource();
  },
);
