import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:zapi/core/constants/api_constants.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/core/network/session_store.dart';

/// Unico lugar de la app que habla HTTP. Traduce todo lo que puede salir
/// mal (sin conexion, timeout, 4xx/5xx, JSON invalido) a [AppException],
/// para que los servicios y las pantallas no dependan del paquete `http`.
///
/// Si hay una sesion iniciada ([SessionStore.token]), TODAS las peticiones
/// mandan `Authorization: Bearer <token>` (las rutas publicas lo ignoran).
class ApiClient {
  ApiClient({
    http.Client? client,
    String? baseUrl,
    Duration? timeout,
    SessionStore? session,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConstants.baseUrl,
        _timeout = timeout ?? ApiConstants.requestTimeout,
        _session = session;

  final http.Client _client;
  final String _baseUrl;
  final Duration _timeout;
  final SessionStore? _session;

  /// [path] debe empezar con "/" y llevar ya codificados sus segmentos.
  Future<dynamic> getJson(String path) {
    return _send(() => _client.get(_uri(path), headers: _headers()));
  }

  Future<dynamic> postJson(String path, Map<String, dynamic> body) {
    return _send(() => _client.post(
          _uri(path),
          headers: _headers(json: true),
          body: jsonEncode(body),
        ));
  }

  Future<dynamic> putJson(String path, Map<String, dynamic> body) {
    return _send(() => _client.put(
          _uri(path),
          headers: _headers(json: true),
          body: jsonEncode(body),
        ));
  }

  /// `PATCH`. Varios endpoints del backend (ocultar / recuperar producto) no
  /// llevan body, por eso es opcional.
  Future<dynamic> patchJson(String path, [Map<String, dynamic>? body]) {
    return _send(() => _client.patch(
          _uri(path),
          headers: _headers(json: body != null),
          body: body == null ? null : jsonEncode(body),
        ));
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Map<String, String> _headers({bool json = false}) {
    final token = _session?.token;
    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(_timeout);
    } on TimeoutException {
      throw const RequestTimeoutException();
    } catch (_) {
      throw const NetworkException();
    }

    final bodyText = utf8.decode(response.bodyBytes, allowMalformed: true);

    // Un 401 con una sesion iniciada significa que el token vencio (dura 8
    // horas) o ya no es valido: se cierra la sesion. Sin sesion (por ejemplo
    // un login con contraseña incorrecta) no hay nada que cerrar.
    if (response.statusCode == 401 && (_session?.hasToken ?? false)) {
      _session!.expire();
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        response.statusCode,
        _errorMessage(bodyText, response.statusCode),
      );
    }

    if (bodyText.trim().isEmpty) return null;
    try {
      return jsonDecode(bodyText);
    } on FormatException {
      throw const DataFormatException('El servidor devolvió una respuesta inválida.');
    }
  }

  /// El backend responde errores como `{"message": "..."}`.
  String _errorMessage(String bodyText, int statusCode) {
    try {
      final decoded = jsonDecode(bodyText);
      if (decoded is Map && decoded['message'] is String) {
        return decoded['message'] as String;
      }
    } on FormatException {
      // Se usa el mensaje generico de abajo.
    }
    return 'Error del servidor ($statusCode).';
  }
}
