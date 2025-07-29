import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/domain/repositories/messages_repository.dart';
import 'package:chat/infrastructure/repositories/messages_repository_impl.dart';
import 'package:chat/infrastructure/providers/messages_providers.dart';

/// Provider para el repositorio de mensajes.
final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  final messagesDataSource = ref.watch(messagesDataSourceProvider);
  return MessagesRepositoryImpl(messagesDataSource);
});
