import 'package:chat/domain/repositories/messages_repository.dart';

/// Use Case para marcar un mensaje como entregado.
///
/// Encapsula la lógica de negocio para marcar
/// un mensaje específico como entregado.
class MarkMessageAsDeliveredUseCase {
  final MessagesRepository _messagesRepository;

  MarkMessageAsDeliveredUseCase(this._messagesRepository);

  /// Ejecuta el use case.
  ///
  /// [mensajeId] ID del mensaje a marcar como entregado
  /// Returns true si se marcó como entregado exitosamente
  /// Throws Exception si hay error marcando el mensaje
  Future<bool> execute(String mensajeId) async {
    try {
      print('🔄 UseCase: Marcando mensaje como entregado: $mensajeId');

      final resultado =
          await _messagesRepository.markMessageAsDelivered(mensajeId);

      if (resultado) {
        print('✅ UseCase: Mensaje marcado como entregado exitosamente');
      } else {
        print('⚠️ UseCase: No se pudo marcar el mensaje como entregado');
      }

      return resultado;
    } catch (e) {
      print('❌ UseCase: Error marcando mensaje como entregado: $e');
      rethrow;
    }
  }
}
