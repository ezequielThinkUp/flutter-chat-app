import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/data/datasources/auth/auth_datasource.dart';
import 'package:chat/data/datasources/auth/auth_remote_datasource.dart';
import 'package:chat/infrastructure/services/auth_service.dart';

/// Provider para el DataSource de autenticación.
///
/// Inyecta la implementación remota que se comunica con la API.
/// Siguiendo Clean Architecture: Repository → DataSource → API Service
final authDataSourceProvider = Provider<AuthDataSource>(
  (ref) {
    final authService = ref.watch(authServiceProvider);
    return AuthRemoteDataSource(authService);
  },
);
