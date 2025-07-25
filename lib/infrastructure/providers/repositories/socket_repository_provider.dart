import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/domain/repositories/socket_repository.dart';
import 'package:chat/infrastructure/repositories/socket_repository_impl.dart';
import 'package:chat/infrastructure/providers/datasources/socket_datasource_provider.dart';
import 'package:chat/infrastructure/providers/repositories/auth_repository_provider.dart';

/// Provider para el SocketRepository.
///
/// Configuración de DI que combina SocketDataSource y AuthRepository
/// para crear una instancia completa del SocketRepository.
final socketRepositoryProvider = Provider<SocketRepository>(
  (ref) {
    final socketDataSource = ref.watch(socketDataSourceProvider);
    final authRepository = ref.watch(authRepositoryProvider);
    return SocketRepositoryImpl(socketDataSource, authRepository);
  },
);
