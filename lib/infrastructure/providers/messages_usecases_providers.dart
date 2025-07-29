import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/domain/usecases/messages/get_messages_between_users_usecase.dart';
import 'package:chat/domain/usecases/messages/get_last_message_usecase.dart';
import 'package:chat/domain/usecases/messages/get_unread_messages_usecase.dart';
import 'package:chat/domain/usecases/messages/mark_message_as_read_usecase.dart';
import 'package:chat/domain/usecases/messages/mark_message_as_delivered_usecase.dart';
import 'package:chat/infrastructure/providers/messages_repository_provider.dart';

/// Provider para el use case de obtener mensajes entre usuarios.
final getMessagesBetweenUsersUseCaseProvider = Provider<GetMessagesBetweenUsersUseCase>((ref) {
  final messagesRepository = ref.watch(messagesRepositoryProvider);
  return GetMessagesBetweenUsersUseCase(messagesRepository);
});

/// Provider para el use case de obtener el último mensaje.
final getLastMessageUseCaseProvider = Provider<GetLastMessageUseCase>((ref) {
  final messagesRepository = ref.watch(messagesRepositoryProvider);
  return GetLastMessageUseCase(messagesRepository);
});

/// Provider para el use case de obtener mensajes no leídos.
final getUnreadMessagesUseCaseProvider = Provider<GetUnreadMessagesUseCase>((ref) {
  final messagesRepository = ref.watch(messagesRepositoryProvider);
  return GetUnreadMessagesUseCase(messagesRepository);
});

/// Provider para el use case de marcar mensaje como leído.
final markMessageAsReadUseCaseProvider = Provider<MarkMessageAsReadUseCase>((ref) {
  final messagesRepository = ref.watch(messagesRepositoryProvider);
  return MarkMessageAsReadUseCase(messagesRepository);
});

/// Provider para el use case de marcar mensaje como entregado.
final markMessageAsDeliveredUseCaseProvider = Provider<MarkMessageAsDeliveredUseCase>((ref) {
  final messagesRepository = ref.watch(messagesRepositoryProvider);
  return MarkMessageAsDeliveredUseCase(messagesRepository);
}); 