import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/infrastructure/services/messages_service.dart';
import 'package:chat/infrastructure/datasources/messages_remote_datasource.dart';
import 'package:chat/domain/datasources/messages_datasource.dart';
import 'package:chat/global/environment.dart';
import 'package:chat/config/networking/dio_provider.dart';

/// Provider para el servicio de mensajes.
final messagesServiceProvider = Provider<MessagesService>((ref) {
  final dio = ref.watch(dioProvider);
  return MessagesService(dio, baseUrl: Environment.apiUrl);
});

/// Provider para el DataSource de mensajes.
final messagesDataSourceProvider = Provider<MessagesDataSource>((ref) {
  final messagesService = ref.watch(messagesServiceProvider);
  return MessagesRemoteDataSource(messagesService);
});
