import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:zapi/core/constants/api_constants.dart';
import 'package:zapi/core/errors/app_exception.dart';

/// Unico lugar de la app que habla HTTP. Traduce todo lo que puede salir
/// mal (sin conexion, timeout, 4xx/5xx, JSON invalido) a [AppException],
/// para que los servicios y las pantallas no dependan del paquete `http`.
class ApiClient {
  ApiClient({http.Client? client, String? baseUrl, Duration? timeout})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConstants.baseUrl,
        _timeout = timeout ?? ApiConstants.requestTimeout;

  final http.Client _client;
  final String _baseUrl;
  final Duration _timeout;

  /// [path] debe empezar con "/" y llevar ya codificados sus segmentos.
  Future<dynamic> getJson(String path) {
    return _send(() => _client.get(
          Uri.parse('$_baseUrl$path'),
          headers: const {'Accept': 'application/json'},
        ));
  }

  Future<dynamic> postJson(String path, Map<String, dynamic> body) {
    return _send(() => _client.post(
          Uri.parse('$_baseUrl$path'),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(body),
        ));
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
