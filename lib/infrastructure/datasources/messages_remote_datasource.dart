import 'package:chat/domain/datasources/messages_datasource.dart';
import 'package:chat/domain/entities/message.dart';
import 'package:chat/infrastructure/services/messages_service.dart';
import 'package:chat/infrastructure/models/message_model.dart';

/// Implementación remota del DataSource de mensajes.
///
/// Se comunica con la API REST para obtener y gestionar mensajes.
class MessagesRemoteDataSource implements MessagesDataSource {
  final MessagesService _messagesService;

  MessagesRemoteDataSource(this._messagesService);

  @override
  Future<List<Message>> getMessagesBetweenUsers({
    required String usuario1,
    required String usuario2,
    int? limite,
    int? offset,
  }) async {
    try {
      print('📥 Obteniendo mensajes entre usuarios: $usuario1 y $usuario2');

      final response = await _messagesService.getMessagesBetweenUsers(
        usuario1: usuario1,
        usuario2: usuario2,
        limite: limite ?? 50,
        offset: offset ?? 0,
      );

      if (response is Map<String, dynamic> &&
          response['ok'] == true &&
          response['mensajes'] != null) {
        final List<dynamic> mensajesJson =
            response['mensajes'] as List<dynamic>;
        final mensajes = mensajesJson
            .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
            .map((model) => model.toDomain())
            .toList();

        print('✅ Mensajes obtenidos: ${mensajes.length}');
        return mensajes;
      } else {
        print('⚠️ No se encontraron mensajes o respuesta inválida');
        return [];
      }
    } catch (e) {
      print('❌ Error obteniendo mensajes: $e');
      throw Exception('Error obteniendo mensajes: $e');
    }
  }

  @override
  Future<Message?> getLastMessage({
    required String usuario1,
    required String usuario2,
  }) async {
    try {
      print(
          '📥 Obteniendo último mensaje entre usuarios: $usuario1 y $usuario2');

      final response = await _messagesService.getLastMessage(
        usuario1: usuario1,
        usuario2: usuario2,
      );

      if (response is Map<String, dynamic> &&
          response['ok'] == true &&
          response['mensaje'] != null) {
        final mensajeJson = response['mensaje'] as Map<String, dynamic>;
        final mensaje = MessageModel.fromJson(mensajeJson).toDomain();

        print('✅ Último mensaje obtenido: ${mensaje.content}');
        return mensaje;
      } else {
        print('⚠️ No se encontró último mensaje');
        return null;
      }
    } catch (e) {
      print('❌ Error obteniendo último mensaje: $e');
      throw Exception('Error obteniendo último mensaje: $e');
    }
  }

  @override
  Future<List<Message>> getUnreadMessages(String usuarioId) async {
    try {
      print('📥 Obteniendo mensajes no leídos para usuario: $usuarioId');

      final response = await _messagesService.getUnreadMessages();

      if (response is Map<String, dynamic> &&
          response['ok'] == true &&
          response['mensajes'] != null) {
        final List<dynamic> mensajesJson =
            response['mensajes'] as List<dynamic>;
        final mensajes = mensajesJson
            .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
            .map((model) => model.toDomain())
            .toList();

        print('✅ Mensajes no leídos obtenidos: ${mensajes.length}');
        return mensajes;
      } else {
        print('⚠️ No se encontraron mensajes no leídos');
        return [];
      }
    } catch (e) {
      print('❌ Error obteniendo mensajes no leídos: $e');
      throw Exception('Error obteniendo mensajes no leídos: $e');
    }
  }

  @override
  Future<bool> markMessageAsRead(String mensajeId) async {
    try {
      print('📝 Marcando mensaje como leído: $mensajeId');

      final response = await _messagesService.markMessageAsRead(mensajeId);

      if (response is Map<String, dynamic> && response['ok'] == true) {
        print('✅ Mensaje marcado como leído exitosamente');
        return true;
      } else {
        print('⚠️ Error marcando mensaje como leído');
        return false;
      }
    } catch (e) {
      print('❌ Error marcando mensaje como leído: $e');
      throw Exception('Error marcando mensaje como leído: $e');
    }
  }

  @override
  Future<bool> markMessageAsDelivered(String mensajeId) async {
    try {
      print('📝 Marcando mensaje como entregado: $mensajeId');

      final response = await _messagesService.markMessageAsDelivered(mensajeId);

      if (response is Map<String, dynamic> && response['ok'] == true) {
        print('✅ Mensaje marcado como entregado exitosamente');
        return true;
      } else {
        print('⚠️ Error marcando mensaje como entregado');
        return false;
      }
    } catch (e) {
      print('❌ Error marcando mensaje como entregado: $e');
      throw Exception('Error marcando mensaje como entregado: $e');
    }
  }
}
