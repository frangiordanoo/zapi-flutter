/// Errores de la capa de datos. Las pantallas y los controladores solo
/// necesitan conocer [AppException] y mostrar su [message]; nunca
/// excepciones de `http` o `dart:io`.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// No se pudo establecer la conexion (sin internet, servidor caido, etc.).
class NetworkException extends AppException {
  const NetworkException()
      : super('No se pudo conectar con el servidor. Revisá tu conexión.');
}

/// El servidor no respondio a tiempo.
class RequestTimeoutException extends AppException {
  const RequestTimeoutException()
      : super('El servidor tardó demasiado en responder. Probá de nuevo.');
}

/// El servidor respondio con un codigo HTTP fuera del rango 2xx.
class ApiException extends AppException {
  const ApiException(this.statusCode, super.message);

  final int statusCode;

  bool get isNotFound => statusCode == 404;
}

/// La respuesta llego bien pero no tiene el formato esperado.
class DataFormatException extends AppException {
  const DataFormatException(super.message);
}

/// La compra no se puede realizar (carrito vacio, producto inexistente,
/// stock insuficiente, etc.). El mensaje se puede mostrar tal cual.
class OrderValidationException extends AppException {
  const OrderValidationException(super.message);
}
