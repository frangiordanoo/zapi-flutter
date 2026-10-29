import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/core/network/api_client.dart';
import 'package:zapi/data/models/product.dart';
import 'package:zapi/data/services/http_product_service.dart';

HttpProductService serviceWith(MockClientHandler handler, {Duration? timeout}) {
  return HttpProductService(ApiClient(
    client: MockClient(handler),
    baseUrl: 'https://api.test',
    timeout: timeout,
  ));
}

http.Response jsonResponse(Object body, [int status = 200]) => http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

const _agua = {
  'id': 180002,
  'code': '7909883138066',
  'name': 'Agua mineral',
  'price': '1500',
  'stock': 17,
  'createdAt': '2026-07-03T12:45:21.818Z',
  'category': 'Bebidas',
};

const _newProduct = Product(
  id: 0,
  code: 'PROD-001',
  name: 'Teclado Mecánico RGB',
  price: 45.99,
  stock: 15,
  category: 'Periféricos',
);

void main() {
  group('GET /products', () {
    test('pide la URL correcta y convierte la lista a Product', () async {
      late http.Request captured;
      final service = serviceWith((request) async {
        captured = request;
        return jsonResponse([
          _agua,
          {..._agua, 'id': 2, 'code': 'X-2', 'name': 'Periférico', 'category': 'Periféricos'},
        ]);
      });

      final products = await service.getProducts();

      expect(captured.method, 'GET');
      expect(captured.url.toString(), 'https://api.test/products');
      expect(products.map((p) => p.code), ['7909883138066', 'X-2']);
      expect(products[1].name, 'Periférico');
    });

    test('lista vacia es valida', () async {
      final service = serviceWith((_) async => jsonResponse([]));
      expect(await service.getProducts(), isEmpty);
    });

    test('ignora un producto roto pero conserva los demas', () async {
      final service = serviceWith((_) async => jsonResponse([_agua, {'id': 9}]));
      final products = await service.getProducts();
      expect(products, hasLength(1));
    });

    test('si ninguno es valido lanza DataFormatException', () async {
      final service =
          serviceWith((_) async => jsonResponse([{'id': 9}, {'foo': 'bar'}]));
      expect(service.getProducts(), throwsA(isA<DataFormatException>()));
    });

    test('si la respuesta no es una lista lanza DataFormatException', () async {
      final service = serviceWith((_) async => jsonResponse({'products': []}));
      expect(service.getProducts(), throwsA(isA<DataFormatException>()));
    });

    test('JSON invalido lanza DataFormatException', () async {
      final service = serviceWith((_) async => http.Response('<html>', 200));
      expect(service.getProducts(), throwsA(isA<DataFormatException>()));
    });

    test('un error HTTP lanza ApiException con el mensaje del servidor', () async {
      final service =
          serviceWith((_) async => jsonResponse({'message': 'Servidor roto'}, 500));
      await expectLater(
        service.getProducts(),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 500)
            .having((e) => e.message, 'message', 'Servidor roto')),
      );
    });

    test('sin conexion lanza NetworkException', () async {
      final service = serviceWith((_) async => throw http.ClientException('sin red'));
      expect(service.getProducts(), throwsA(isA<NetworkException>()));
    });

    test('timeout lanza RequestTimeoutException', () async {
      final service = serviceWith(
        (_) => Completer<http.Response>().future,
        timeout: const Duration(milliseconds: 20),
      );
      expect(service.getProducts(), throwsA(isA<RequestTimeoutException>()));
    });
  });

  group('GET /products/:code', () {
    test('devuelve el producto encontrado', () async {
      late http.Request captured;
      final service = serviceWith((request) async {
        captured = request;
        return jsonResponse(_agua);
      });

      final product = await service.getProductByCode('7909883138066');

      expect(captured.url.toString(), 'https://api.test/products/7909883138066');
      expect(product?.name, 'Agua mineral');
    });

    test('un 404 devuelve null (producto inexistente)', () async {
      final service = serviceWith((_) async =>
          jsonResponse({'message': 'Este producto no pertenece al negocio.'}, 404));
      expect(await service.getProductByCode('NOEXISTE'), isNull);
    });

    test('otros errores HTTP se propagan', () async {
      final service = serviceWith((_) async => jsonResponse({'message': 'boom'}, 500));
      expect(service.getProductByCode('1'), throwsA(isA<ApiException>()));
    });

    test('codifica caracteres especiales en la URL', () async {
      late Uri captured;
      final service = serviceWith((request) async {
        captured = request.url;
        return jsonResponse({..._agua, 'code': '00A/1 b'});
      });

      await service.getProductByCode('00A/1 b');

      expect(captured.toString(), 'https://api.test/products/00A%2F1%20b');
    });
  });

  group('POST /products', () {
    test('envia el body anidado dentro de "product" con Content-Type JSON', () async {
      late http.Request captured;
      final service = serviceWith((request) async {
        captured = request;
        return jsonResponse({..._agua, 'id': 99, 'code': 'PROD-001'}, 201);
      });

      final created = await service.createProduct(_newProduct);

      expect(captured.method, 'POST');
      expect(captured.url.toString(), 'https://api.test/products');
      expect(captured.headers['Content-Type'], startsWith('application/json'));
      expect(jsonDecode(captured.body), {
        'product': {
          'code': 'PROD-001',
          'name': 'Teclado Mecánico RGB',
          'price': 45.99,
          'stock': 15,
          'category': 'Periféricos',
        },
      });
      expect(created.id, 99);
    });

    test('si la respuesta no trae el producto igual devuelve el enviado', () async {
      final service = serviceWith((_) async => jsonResponse({'ok': true}, 201));
      final created = await service.createProduct(_newProduct);
      expect(created.code, 'PROD-001');
    });

    test('un error del servidor se propaga con su mensaje', () async {
      final service = serviceWith(
          (_) async => jsonResponse({'message': 'El código ya existe'}, 400));
      await expectLater(
        service.createProduct(_newProduct),
        throwsA(isA<ApiException>()
            .having((e) => e.message, 'message', 'El código ya existe')),
      );
    });
  });
}
