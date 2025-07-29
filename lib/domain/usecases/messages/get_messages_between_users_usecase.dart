import 'package:chat/domain/entities/message.dart';
import 'package:chat/domain/repositories/messages_repository.dart';

/// Use Case para obtener mensajes entre dos usuarios.
///
/// Encapsula la lógica de negocio para obtener mensajes
/// entre dos usuarios específicos.
class GetMessagesBetweenUsersUseCase {
  final MessagesRepository _messagesRepository;

  GetMessagesBetweenUsersUseCase(this._messagesRepository);

  /// Ejecuta el use case.
  ///
  /// [usuario1] ID del primer usuario
  /// [usuario2] ID del segundo usuario
  /// [limite] Número máximo de mensajes a obtener
  /// [offset] Número de mensajes a saltar
  /// Returns Lista de mensajes ordenados por timestamp
  /// Throws Exception si hay error obteniendo los mensajes
  Future<List<Message>> execute({
    required String usuario1,
    required String usuario2,
    int? limite,
    int? offset,
  }) async {
    try {
      print('🔄 UseCase: Obteniendo mensajes entre usuarios');

      final mensajes = await _messagesRepository.getMessagesBetweenUsers(
        usuario1: usuario1,
        usuario2: usuario2,
        limite: limite,
        offset: offset,
      );

      print('✅ UseCase: ${mensajes.length} mensajes obtenidos');
      return mensajes;
    } catch (e) {
      print('❌ UseCase: Error obteniendo mensajes: $e');
      rethrow;
    }
  }
}
