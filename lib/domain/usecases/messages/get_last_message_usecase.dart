import 'package:chat/domain/entities/message.dart';
import 'package:chat/domain/repositories/messages_repository.dart';

/// Use Case para obtener el último mensaje entre dos usuarios.
///
/// Encapsula la lógica de negocio para obtener el último
/// mensaje intercambiado entre dos usuarios.
class GetLastMessageUseCase {
  final MessagesRepository _messagesRepository;

  GetLastMessageUseCase(this._messagesRepository);

  /// Ejecuta el use case.
  ///
  /// [usuario1] ID del primer usuario
  /// [usuario2] ID del segundo usuario
  /// Returns El último mensaje o null si no hay mensajes
  /// Throws Exception si hay error obteniendo el mensaje
  Future<Message?> execute({
    required String usuario1,
    required String usuario2,
  }) async {
    try {
      print('🔄 UseCase: Obteniendo último mensaje entre usuarios');

      final mensaje = await _messagesRepository.getLastMessage(
        usuario1: usuario1,
        usuario2: usuario2,
      );

      if (mensaje != null) {
        print('✅ UseCase: Último mensaje obtenido: ${mensaje.content}');
      } else {
        print('ℹ️ UseCase: No hay mensajes entre estos usuarios');
      }

      return mensaje;
    } catch (e) {
      print('❌ UseCase: Error obteniendo último mensaje: $e');
      rethrow;
    }
  }
}
