import 'package:chat/domain/repositories/messages_repository.dart';
import 'package:chat/domain/datasources/messages_datasource.dart';
import 'package:chat/domain/entities/message.dart';

/// Implementación del repositorio de mensajes.
///
/// Orquesta las operaciones entre diferentes DataSources
/// y aplica lógica de negocio adicional.
class MessagesRepositoryImpl implements MessagesRepository {
  final MessagesDataSource _messagesDataSource;

  MessagesRepositoryImpl(this._messagesDataSource);

  @override
  Future<List<Message>> getMessagesBetweenUsers({
    required String usuario1,
    required String usuario2,
    int? limite,
    int? offset,
  }) async {
    try {
      print('🔄 Repositorio: Obteniendo mensajes entre usuarios');

      final mensajes = await _messagesDataSource.getMessagesBetweenUsers(
        usuario1: usuario1,
        usuario2: usuario2,
        limite: limite,
        offset: offset,
      );

      // Ordenar mensajes por timestamp (más recientes primero)
      mensajes.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      print('✅ Repositorio: ${mensajes.length} mensajes obtenidos y ordenados');
      return mensajes;
    } catch (e) {
      print('❌ Repositorio: Error obteniendo mensajes: $e');
      rethrow;
    }
  }

  @override
  Future<Message?> getLastMessage({
    required String usuario1,
    required String usuario2,
  }) async {
    try {
      print('🔄 Repositorio: Obteniendo último mensaje');

      final mensaje = await _messagesDataSource.getLastMessage(
        usuario1: usuario1,
        usuario2: usuario2,
      );

      if (mensaje != null) {
        print('✅ Repositorio: Último mensaje obtenido: ${mensaje.content}');
      } else {
        print('ℹ️ Repositorio: No hay mensajes entre estos usuarios');
      }

      return mensaje;
    } catch (e) {
      print('❌ Repositorio: Error obteniendo último mensaje: $e');
      rethrow;
    }
  }

  @override
  Future<List<Message>> getUnreadMessages(String usuarioId) async {
    try {
      print(
          '🔄 Repositorio: Obteniendo mensajes no leídos para usuario: $usuarioId');

      final mensajes = await _messagesDataSource.getUnreadMessages(usuarioId);

      // Filtrar mensajes que realmente son para este usuario
      final mensajesFiltrados =
          mensajes.where((mensaje) => mensaje.receiverId == usuarioId).toList();

      print(
          '✅ Repositorio: ${mensajesFiltrados.length} mensajes no leídos obtenidos');
      return mensajesFiltrados;
    } catch (e) {
      print('❌ Repositorio: Error obteniendo mensajes no leídos: $e');
      rethrow;
    }
  }

  @override
  Future<bool> markMessageAsRead(String mensajeId) async {
    try {
      print('🔄 Repositorio: Marcando mensaje como leído: $mensajeId');

      final resultado = await _messagesDataSource.markMessageAsRead(mensajeId);

      if (resultado) {
        print('✅ Repositorio: Mensaje marcado como leído exitosamente');
      } else {
        print('⚠️ Repositorio: No se pudo marcar el mensaje como leído');
      }

      return resultado;
    } catch (e) {
      print('❌ Repositorio: Error marcando mensaje como leído: $e');
      rethrow;
    }
  }

  @override
  Future<bool> markMessageAsDelivered(String mensajeId) async {
    try {
      print('🔄 Repositorio: Marcando mensaje como entregado: $mensajeId');

      final resultado =
          await _messagesDataSource.markMessageAsDelivered(mensajeId);

      if (resultado) {
        print('✅ Repositorio: Mensaje marcado como entregado exitosamente');
      } else {
        print('⚠️ Repositorio: No se pudo marcar el mensaje como entregado');
      }

      return resultado;
    } catch (e) {
      print('❌ Repositorio: Error marcando mensaje como entregado: $e');
      rethrow;
    }
  }
}
