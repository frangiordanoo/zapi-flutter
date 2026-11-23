/// Guarda el token JWT de la sesion de administrador mientras la app esta
/// abierta. [ApiClient] lo lee en cada peticion para mandar
/// `Authorization: Bearer <token>`; [AuthController] lo escribe al hacer
/// login/logout.
///
/// Vive solo en memoria a proposito (no hay almacenamiento persistente): el
/// token dura 8 horas en el backend y, si se cierra la app, hay que volver a
/// iniciar sesion.
class SessionStore {
  String? token;

  /// Se llama cuando el servidor rechaza el token (401): vencio o dejo de
  /// ser valido. [AuthController] lo usa para cerrar la sesion, igual que el
  /// frontend web (`auth:unauthorized`).
  void Function()? onExpired;

  bool get hasToken => token != null && token!.isNotEmpty;

  void clear() => token = null;

  /// El token ya no sirve: se descarta y se avisa.
  void expire() {
    clear();
    onExpired?.call();
  }
}
