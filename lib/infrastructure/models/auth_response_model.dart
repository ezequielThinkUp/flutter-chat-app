import 'package:chat/domain/entities/auth_result.dart';
import 'package:chat/domain/entities/user.dart';

/// Modelo de datos para la respuesta de autenticación del servidor.
///
/// Maneja la serialización/deserialización JSON y la conversión
/// hacia entidades de dominio.
class AuthResponseModel {
  final bool ok;
  final String token;
  final UserModel usuario;
  final String? mensaje;

  const AuthResponseModel({
    required this.ok,
    required this.token,
    required this.usuario,
    this.mensaje,
  });

  /// Crea desde JSON manualmente.
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      ok: json['ok'] as bool? ?? false,
      token: json['token'] as String? ?? '',
      usuario: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      mensaje: json['msg'] as String?,
    );
  }

  /// Convierte a JSON manualmente.
  Map<String, dynamic> toJson() {
    return {
      'ok': ok,
      'token': token,
      'usuario': usuario.toJson(),
      'mensaje': mensaje,
    };
  }

  /// Convierte a entidad de dominio.
  AuthResult toDomain() {
    if (!ok) {
      throw Exception(mensaje ?? 'Error de autenticación');
    }

    return AuthResult(
      user: usuario.toDomain(),
      token: token,
      expiresAt: DateTime.now().add(const Duration(hours: 24)), // Placeholder
    );
  }

  @override
  String toString() => 'AuthResponseModel(ok: $ok, usuario: $usuario)';
}

/// Modelo del usuario en la respuesta.
class UserModel {
  final String uid;
  final String nombre;
  final String email;
  final bool online;

  const UserModel({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.online,
  });

  /// Crea desde JSON manualmente.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['id'] as String? ?? '',
      nombre: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      online: json['online'] as bool? ?? false,
    );
  }

  /// Convierte a JSON manualmente.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nombre': nombre,
      'email': email,
      'online': online,
    };
  }

  /// Convierte a entidad de dominio.
  User toDomain() {
    return User(
      id: uid,
      name: nombre,
      email: email,
      isOnline: online,
    );
  }

  @override
  String toString() => 'UserModel(uid: $uid, nombre: $nombre, email: $email)';
}
