import 'package:flutter/foundation.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/core/network/session_store.dart';
import 'package:zapi/data/models/auth_user.dart';
import 'package:zapi/data/services/auth_service.dart';

/// Estado de la sesion del administrador.
///
/// Solo se acepta un usuario con rol ADMIN (igual que `ProtectedRoute` del
/// frontend web): un EMPLOYEE puede autenticarse en el backend pero no
/// tiene permisos para ninguna pantalla administrativa, asi que se rechaza
/// el login y no se guarda el token.
class AuthController extends ChangeNotifier {
  AuthController(this._service, this._session) {
    _session.onExpired = _handleExpired;
  }

  final AuthService _service;
  final SessionStore _session;

  AuthUser? user;
  bool isLoading = false;
  String? errorMessage;

  bool get isAdmin => user?.isAdmin ?? false;

  /// `true` si el login fue exitoso y el usuario es ADMIN.
  Future<bool> login(String username, String password) async {
    if (isLoading) return false;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final session = await _service.login(username.trim(), password);
      if (!session.user.isAdmin) {
        errorMessage = 'Tu usuario no tiene permisos de administrador.';
        return false;
      }
      _session.token = session.token;
      user = session.user;
      return true;
    } on AppException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _session.clear();
    user = null;
    errorMessage = null;
    notifyListeners();
  }

  /// El servidor rechazo el token (vencido o invalido): se cierra la sesion
  /// y las pantallas de administrador vuelven al login.
  void _handleExpired() {
    user = null;
    errorMessage = 'Tu sesión venció. Iniciá sesión nuevamente.';
    notifyListeners();
  }
}
