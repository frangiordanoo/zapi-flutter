import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/core/network/api_client.dart';
import 'package:zapi/core/network/session_store.dart';
import 'package:zapi/data/services/auth_service.dart';
import 'package:zapi/data/services/http_product_service.dart';
import 'package:zapi/state/auth_controller.dart';

http.Response json(Object body, [int status = 200]) => http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

/// Igual que el frontend web (`auth:unauthorized`): si el servidor rechaza el
/// token (vencio, 8 horas) se cierra la sesion.
void main() {
  late SessionStore session;
  late List<String> paths;

  ApiClient clientWith(http.Response Function(http.Request) handler) {
    paths = [];
    return ApiClient(
      baseUrl: 'https://api.test',
      session: session,
      client: MockClient((request) async {
        paths.add(request.url.path);
        return handler(request);
      }),
    );
  }

  setUp(() => session = SessionStore());

  test('un 401 con sesion iniciada descarta el token y avisa', () async {
    session.token = 'JWT-VENCIDO';
    var expired = 0;
    session.onExpired = () => expired++;
    final api = clientWith((_) => json({'message': 'No autorizado'}, 401));

    await expectLater(
      api.getJson('/products/all'),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401)),
    );

    expect(session.hasToken, isFalse);
    expect(expired, 1);
  });

  test('un 401 SIN sesion (login con clave mala) no cierra nada', () async {
    var expired = 0;
    session.onExpired = () => expired++;
    final api = clientWith(
        (_) => json({'message': 'Usuario o contraseña incorrectos'}, 401));

    await expectLater(
      api.postJson('/auth/login', {'username': 'x', 'password': 'y'}),
      throwsA(isA<ApiException>()),
    );

    expect(expired, 0);
  });

  test('otros errores (403, 404, 500) no cierran la sesion', () async {
    session.token = 'JWT';
    var expired = 0;
    session.onExpired = () => expired++;

    for (final status in [403, 404, 409, 500]) {
      final api = clientWith((_) => json({'message': 'x'}, status));
      await expectLater(api.getJson('/products/all'), throwsA(isA<ApiException>()));
    }

    expect(expired, 0);
    expect(session.hasToken, isTrue);
  });

  test('AuthController: si el token vence, deja de ser admin y explica por que', () async {
    final api = clientWith((request) {
      if (request.url.path == '/auth/login') {
        return json({
          'token': 'JWT',
          'user': {'id': 1, 'username': 'admin', 'role': 'ADMIN'},
        });
      }
      return json({'message': 'No autorizado'}, 401); // el token vencio
    });
    final auth = AuthController(HttpAuthService(api), session);

    expect(await auth.login('admin', 'x'), isTrue);
    expect(auth.isAdmin, isTrue);

    // Una operacion de administrador se hace con el token vencido.
    await expectLater(
      HttpProductService(api).getAllProducts(),
      throwsA(isA<ApiException>()),
    );

    expect(auth.isAdmin, isFalse);
    expect(session.hasToken, isFalse);
    expect(auth.errorMessage, 'Tu sesión venció. Iniciá sesión nuevamente.');
  });

  test('AuthController: un login nuevo despues de vencer limpia el aviso', () async {
    final api = clientWith((_) => json({
          'token': 'JWT2',
          'user': {'id': 1, 'username': 'admin', 'role': 'ADMIN'},
        }));
    final auth = AuthController(HttpAuthService(api), session);
    session.token = 'viejo';
    session.expire();
    expect(auth.errorMessage, isNotNull);

    expect(await auth.login('admin', 'x'), isTrue);

    expect(auth.errorMessage, isNull);
    expect(session.token, 'JWT2');
  });
}
