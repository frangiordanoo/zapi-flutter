import 'package:zapi/core/errors/app_exception.dart';

/// Roles del backend. Solo ADMIN puede usar las rutas administrativas;
/// EMPLOYEE no tiene permisos de gestion.
enum UserRole { admin, employee }

/// Usuario autenticado: `{"id": 1, "username": "admin", "role": "ADMIN"}`.
class AuthUser {
  final int id;
  final String username;
  final UserRole role;

  const AuthUser({required this.id, required this.username, required this.role});

  bool get isAdmin => role == UserRole.admin;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final username = json['username'];
    final role = switch (json['role']) {
      'ADMIN' => UserRole.admin,
      'EMPLOYEE' => UserRole.employee,
      _ => null,
    };
    if (id is! num || username is! String || role == null) {
      throw const DataFormatException('El usuario del servidor tiene un formato inesperado.');
    }
    return AuthUser(id: id.toInt(), username: username, role: role);
  }
}

/// Resultado de `POST /auth/login`.
class AuthSession {
  final String token;
  final AuthUser user;

  const AuthSession({required this.token, required this.user});
}
