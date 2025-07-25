import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/domain/datasources/socket_datasource.dart';
import 'package:chat/infrastructure/datasources/socket_remote_datasource.dart';
import 'package:chat/infrastructure/services/socket_service.dart';

/// Provider para el DataSource de Socket.
///
/// Configuración de DI para SocketDataSource.
/// Ubicado en infrastructure/providers/datasources/ para separar
/// la configuración de DI de las implementaciones.
final socketDataSourceProvider = Provider<SocketDataSource>(
  (ref) {
    final socketService = ref.watch(socketServiceProvider);
    return SocketRemoteDataSource(socketService);
  },
);
