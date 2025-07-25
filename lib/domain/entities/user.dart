/// Entidad de dominio para representar un usuario.
///
/// Contiene la lógica de negocio pura sin dependencias externas.
class User {
  final String id;
  final String name;
  final String email;
  final bool isOnline;
  final DateTime? lastSeen;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.isOnline,
    this.lastSeen,
  });

  /// Copia el usuario con nuevos valores.
  User copyWith({
    String? id,
    String? name,
    String? email,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  /// Convierte a modelo de datos para persistencia.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }

  /// Crea desde modelo de datos.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      isOnline: json['isOnline'] as bool,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.isOnline == isOnline &&
        other.lastSeen == lastSeen;
  }

  @override
  int get hashCode => Object.hash(id, name, email, isOnline, lastSeen);

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, isOnline: $isOnline)';
  }
}
