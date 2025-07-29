import 'package:chat/domain/repositories/messages_repository.dart';

/// Use Case para marcar un mensaje como leído.
///
/// Encapsula la lógica de negocio para marcar
/// un mensaje específico como leído.
class MarkMessageAsReadUseCase {
  final MessagesRepository _messagesRepository;

  MarkMessageAsReadUseCase(this._messagesRepository);

  /// Ejecuta el use case.
  ///
  /// [mensajeId] ID del mensaje a marcar como leído
  /// Returns true si se marcó como leído exitosamente
  /// Throws Exception si hay error marcando el mensaje
  Future<bool> execute(String mensajeId) async {
    try {
      print('🔄 UseCase: Marcando mensaje como leído: $mensajeId');

      final resultado = await _messagesRepository.markMessageAsRead(mensajeId);

      if (resultado) {
        print('✅ UseCase: Mensaje marcado como leído exitosamente');
      } else {
        print('⚠️ UseCase: No se pudo marcar el mensaje como leído');
      }

      return resultado;
    } catch (e) {
      print('❌ UseCase: Error marcando mensaje como leído: $e');
      rethrow;
    }
  }
}
