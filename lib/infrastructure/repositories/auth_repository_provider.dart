import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/domain/repositories/auth_repository.dart';
import 'package:chat/infrastructure/repositories/auth_repository_impl.dart';
import 'package:chat/data/datasources/auth/auth_datasource_provider.dart';
import 'package:chat/infrastructure/storage/secure_storage.dart';

/// Provider para el repositorio de autenticación.
///
/// Inyecta la implementación con DataSource abstraction.
/// Siguiendo Clean Architecture: Repository → DataSource → API Service
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) {
    final authDataSource = ref.watch(authDataSourceProvider);
    final secureStorage = SecureStorage();
    return AuthRepositoryImpl(authDataSource, secureStorage);
  },
);

/// Provider para SecureStorage (singleton).
final secureStorageProvider = Provider<SecureStorage>(
  (ref) => SecureStorage(),
);
