import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/data/datasources/users/users_datasource.dart';
import 'package:chat/data/datasources/users/users_remote_datasource.dart';

/// Provider para el DataSource de usuarios.
///
/// Inyecta la implementación remota (por ahora mock).
/// Siguiendo Clean Architecture: Repository → DataSource → API Service
final usersDataSourceProvider = Provider<UsersDataSource>(
  (ref) {
    // TODO: Inyectar UsersService cuando esté disponible
    return const UsersRemoteDataSource();
  },
);
