import 'package:chat/domain/entities/message.dart';

/// Interface que define las operaciones de mensajes.
///
/// Esta abstracción permite cambiar la implementación de mensajes
/// sin afectar la lógica del repositorio.
abstract class MessagesDataSource {
  /// Obtiene mensajes entre dos usuarios.
  ///
  /// [usuario1] ID del primer usuario
  /// [usuario2] ID del segundo usuario
  /// [limite] Número máximo de mensajes a obtener
  /// [offset] Número de mensajes a saltar
  /// Returns Lista de mensajes
  /// Throws Exception si hay error obteniendo los mensajes
  Future<List<Message>> getMessagesBetweenUsers({
    required String usuario1,
    required String usuario2,
    int? limite,
    int? offset,
  });

  /// Obtiene el último mensaje entre dos usuarios.
  ///
  /// [usuario1] ID del primer usuario
  /// [usuario2] ID del segundo usuario
  /// Returns El último mensaje o null si no hay mensajes
  /// Throws Exception si hay error obteniendo el mensaje
  Future<Message?> getLastMessage({
    required String usuario1,
    required String usuario2,
  });

  /// Obtiene mensajes no leídos del usuario.
  ///
  /// [usuarioId] ID del usuario
  /// Returns Lista de mensajes no leídos
  /// Throws Exception si hay error obteniendo los mensajes
  Future<List<Message>> getUnreadMessages(String usuarioId);

  /// Marca un mensaje como leído.
  ///
  /// [mensajeId] ID del mensaje
  /// Returns true si se marcó como leído exitosamente
  /// Throws Exception si hay error marcando el mensaje
  Future<bool> markMessageAsRead(String mensajeId);

  /// Marca un mensaje como entregado.
  ///
  /// [mensajeId] ID del mensaje
  /// Returns true si se marcó como entregado exitosamente
  /// Throws Exception si hay error marcando el mensaje
  Future<bool> markMessageAsDelivered(String mensajeId);
}
