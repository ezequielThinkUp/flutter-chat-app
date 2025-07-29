import 'package:chat/domain/entities/message.dart';
import 'package:chat/domain/repositories/messages_repository.dart';

/// Use Case para obtener mensajes no leídos de un usuario.
///
/// Encapsula la lógica de negocio para obtener todos
/// los mensajes no leídos de un usuario específico.
class GetUnreadMessagesUseCase {
  final MessagesRepository _messagesRepository;

  GetUnreadMessagesUseCase(this._messagesRepository);

  /// Ejecuta el use case.
  ///
  /// [usuarioId] ID del usuario
  /// Returns Lista de mensajes no leídos
  /// Throws Exception si hay error obteniendo los mensajes
  Future<List<Message>> execute(String usuarioId) async {
    try {
      print(
          '🔄 UseCase: Obteniendo mensajes no leídos para usuario: $usuarioId');

      final mensajes = await _messagesRepository.getUnreadMessages(usuarioId);

      print('✅ UseCase: ${mensajes.length} mensajes no leídos obtenidos');
      return mensajes;
    } catch (e) {
      print('❌ UseCase: Error obteniendo mensajes no leídos: $e');
      rethrow;
    }
  }
}
