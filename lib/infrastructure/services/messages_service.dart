import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:chat/infrastructure/models/message_model.dart';

part 'messages_service.g.dart';

/// Servicio para manejar operaciones de mensajes con la API.
@RestApi()
abstract class MessagesService {
  factory MessagesService(Dio dio, {String baseUrl}) = _MessagesService;

  /// Obtiene mensajes entre dos usuarios.
  @GET('/mensajes/entre-usuarios')
  Future<dynamic> getMessagesBetweenUsers({
    @Query('usuario1') required String usuario1,
    @Query('usuario2') required String usuario2,
    @Query('limite') int? limite,
    @Query('offset') int? offset,
  });

  /// Obtiene el último mensaje entre dos usuarios.
  @GET('/mensajes/ultimo')
  Future<dynamic> getLastMessage({
    @Query('usuario1') required String usuario1,
    @Query('usuario2') required String usuario2,
  });

  /// Obtiene mensajes no leídos del usuario.
  @GET('/mensajes/no-leidos')
  Future<dynamic> getUnreadMessages();

  /// Marca un mensaje como leído.
  @PUT('/mensajes/{mensajeId}/leido')
  Future<dynamic> markMessageAsRead(@Path('mensajeId') String mensajeId);

  /// Marca un mensaje como entregado.
  @PUT('/mensajes/{mensajeId}/entregado')
  Future<dynamic> markMessageAsDelivered(@Path('mensajeId') String mensajeId);

  /// Busca mensajes por contenido.
  @GET('/mensajes/buscar')
  Future<dynamic> searchMessages({
    @Query('query') required String query,
    @Query('usuario1') required String usuario1,
    @Query('usuario2') required String usuario2,
    @Query('limite') int? limite,
  });
}
