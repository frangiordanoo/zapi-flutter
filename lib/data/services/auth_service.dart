import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/core/network/api_client.dart';
import 'package:zapi/data/models/auth_user.dart';

/// Contrato de autenticacion contra el backend (para poder falsearlo en tests).
abstract class AuthService {
  /// `POST /auth/login`. Lanza [ApiException] 401 si las credenciales son
  /// incorrectas ("Usuario o contraseña incorrectos").
  Future<AuthSession> login(String username, String password);

  /// `GET /auth/me` con el token ya guardado en la sesion.
  Future<AuthUser> me();
}

class HttpAuthService implements AuthService {
  HttpAuthService(this._api);

  final ApiClient _api;

  @override
  Future<AuthSession> login(String username, String password) async {
    final json = await _api.postJson('/auth/login', {
      'username': username,
      'password': password,
    });
    if (json is! Map<String, dynamic> ||
        json['token'] is! String ||
        json['user'] is! Map<String, dynamic>) {
      throw const DataFormatException('La respuesta del login tiene un formato inesperado.');
    }
    return AuthSession(
      token: json['token'] as String,
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  @override
  Future<AuthUser> me() async {
    final json = await _api.getJson('/auth/me');
    if (json is! Map<String, dynamic> || json['user'] is! Map<String, dynamic>) {
      throw const DataFormatException('La respuesta de la sesión tiene un formato inesperado.');
    }
    return AuthUser.fromJson(json['user'] as Map<String, dynamic>);
  }
}
