import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/core/network/api_client.dart';
import 'package:zapi/core/network/session_store.dart';
import 'package:zapi/data/models/cart_item.dart';
import 'package:zapi/data/models/product.dart';
import 'package:zapi/data/models/stock_review.dart';
import 'package:zapi/data/repositories/stats_repository.dart';
import 'package:zapi/data/models/sale.dart';
import 'package:zapi/data/services/auth_service.dart';
import 'package:zapi/data/services/checkout_service.dart';
import 'package:zapi/data/services/http_product_service.dart';
import 'package:zapi/data/services/http_sales_data_source.dart';
import 'package:zapi/state/auth_controller.dart';

import '../support/fakes.dart';

/// Verifica, request por request, que la app habla con el backend como
/// documenta `Endpoint de backend Zapi.pdf` (y como lo implementa el repo
/// del backend): metodo, URL, headers y body.
http.Response json(Object body, [int status = 200]) => http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

const _oreo = {
  'id': 1,
  'code': '7791813888468',
  'name': 'Galletitas Oreo',
  'price': '1800',
  'stock': 24,
  'category': 'Almacén',
  'isActive': true,
  'createdAt': '2026-11-23T12:00:00.000Z',
};

void main() {
  late List<http.Request> requests;
  late SessionStore session;

  ApiClient clientWith(Future<http.Response> Function(http.Request) handler) {
    requests = [];
    return ApiClient(
      baseUrl: 'https://api.test',
      session: session,
      client: MockClient((request) {
        requests.add(request);
        return handler(request);
      }),
    );
  }

  setUp(() => session = SessionStore());

  group('Authorization', () {
    test('sin sesion no manda el header Authorization', () async {
      final api = clientWith((_) async => json([]));
      await api.getJson('/products');
      expect(requests.single.headers.containsKey('Authorization'), isFalse);
    });

    test('con sesion manda Bearer <token> en cada peticion', () async {
      session.token = 'JWT123';
      final api = clientWith((_) async => json({}));

      await api.getJson('/products/all');
      await api.patchJson('/products/A');

      expect(requests.map((r) => r.headers['Authorization']), ['Bearer JWT123', 'Bearer JWT123']);
    });
  });

  group('auth', () {
    test('POST /auth/login con username y password', () async {
      final service = HttpAuthService(clientWith((_) async => json({
            'token': 'JWT',
            'user': {'id': 1, 'username': 'admin', 'role': 'ADMIN'},
          })));

      final result = await service.login('admin', '123456');

      expect(requests.single.method, 'POST');
      expect(requests.single.url.path, '/auth/login');
      expect(jsonDecode(requests.single.body), {'username': 'admin', 'password': '123456'});
      expect(result.token, 'JWT');
      expect(result.user.isAdmin, isTrue);
    });

    test('AuthController guarda el token solo si el rol es ADMIN', () async {
      final admin = AuthController(
        HttpAuthService(clientWith((_) async => json({
              'token': 'JWT',
              'user': {'id': 1, 'username': 'admin', 'role': 'ADMIN'},
            }))),
        session,
      );
      expect(await admin.login('admin', 'x'), isTrue);
      expect(session.token, 'JWT');
      expect(admin.isAdmin, isTrue);

      admin.logout();
      expect(session.hasToken, isFalse);
      expect(admin.isAdmin, isFalse);
    });

    test('un EMPLOYEE es rechazado y no se guarda su token', () async {
      final controller = AuthController(
        HttpAuthService(clientWith((_) async => json({
              'token': 'JWT-EMP',
              'user': {'id': 2, 'username': 'caja', 'role': 'EMPLOYEE'},
            }))),
        session,
      );

      expect(await controller.login('caja', 'x'), isFalse);
      expect(controller.errorMessage, 'Tu usuario no tiene permisos de administrador.');
      expect(session.hasToken, isFalse);
    });

    test('credenciales incorrectas muestran el mensaje del backend (401)', () async {
      final controller = AuthController(
        HttpAuthService(clientWith(
            (_) async => json({'message': 'Usuario o contraseña incorrectos'}, 401))),
        session,
      );

      expect(await controller.login('admin', 'mal'), isFalse);
      expect(controller.errorMessage, 'Usuario o contraseña incorrectos');
      expect(session.hasToken, isFalse);
    });
  });

  group('productos admin', () {
    late HttpProductService service;
    setUp(() {
      session.token = 'JWT';
      service = HttpProductService(clientWith((_) async => json({'message': 'ok', 'product': _oreo})));
    });

    test('GET /products/all', () async {
      final all = HttpProductService(clientWith((_) async => json([_oreo, {..._oreo, 'id': 2, 'code': 'X', 'isActive': false}])));
      final products = await all.getAllProducts();

      expect(requests.single.url.path, '/products/all');
      expect(products.map((p) => p.isActive), [true, false]);
    });

    test('PUT /products/:code manda solo name y price (price numerico)', () async {
      await service.updateProduct('7791813888468', name: 'Oreo grandes', price: 2000);

      expect(requests.single.method, 'PUT');
      expect(requests.single.url.path, '/products/7791813888468');
      expect(jsonDecode(requests.single.body), {'name': 'Oreo grandes', 'price': 2000});
    });

    test('PATCH /products/:code oculta, sin body', () async {
      await service.hideProduct('7791813888468');

      expect(requests.single.method, 'PATCH');
      expect(requests.single.url.path, '/products/7791813888468');
      expect(requests.single.body, isEmpty);
    });

    test('PATCH /products/:code/restore', () async {
      await service.restoreProduct('7791813888468');

      expect(requests.single.method, 'PATCH');
      expect(requests.single.url.path, '/products/7791813888468/restore');
    });

    test('PATCH /products/:code/stock manda {quantity}', () async {
      await service.addStock('7791813888468', 10);

      expect(requests.single.method, 'PATCH');
      expect(requests.single.url.path, '/products/7791813888468/stock');
      expect(jsonDecode(requests.single.body), {'quantity': 10});
    });

    test('un 403 (no ADMIN) llega como ApiException con isForbidden', () async {
      final forbidden = HttpProductService(
          clientWith((_) async => json({'message': 'Acceso denegado'}, 403)));

      await expectLater(
        forbidden.hideProduct('A'),
        throwsA(isA<ApiException>().having((e) => e.isForbidden, 'isForbidden', isTrue)),
      );
    });

    test('POST /products/review-stock manda {products:[{code,physicalStock}]}', () async {
      final review = HttpProductService(clientWith((_) async => json({
            'message': 'Revisión de stock completada.',
            'results': [
              {
                'product': {'code': '7791813888468', 'name': 'Galletitas Oreo'},
                'databaseStock': 24,
                'physicalStock': 20,
                'difference': 4,
                'status': 'missing',
              }
            ],
          })));

      final results = await review.reviewStock(
          const [StockCount(code: '7791813888468', physicalStock: 20)]);

      expect(requests.single.method, 'POST');
      expect(requests.single.url.path, '/products/review-stock');
      expect(jsonDecode(requests.single.body), {
        'products': [
          {'code': '7791813888468', 'physicalStock': 20}
        ]
      });
      expect(results.single.status, StockReviewStatus.missing);
      expect(results.single.difference, 4);
      expect(results.single.name, 'Galletitas Oreo');
    });
  });

  group('ventas', () {
    test('POST /sales/checkout manda productId (id numerico) y quantity', () async {
      final service = HttpCheckoutService(clientWith(
          (_) async => json({'url': 'https://www.mercadopago.com.ar/checkout?pref=1'})));

      final url = await service.createCheckout([
        CartItem(product: testProduct(id: 7, code: 'A'), quantity: 2),
        CartItem(product: testProduct(id: 9, code: 'B')),
      ]);

      expect(requests.single.method, 'POST');
      expect(requests.single.url.path, '/sales/checkout');
      expect(jsonDecode(requests.single.body), {
        'cart': [
          {'productId': 7, 'quantity': 2},
          {'productId': 9, 'quantity': 1},
        ]
      });
      expect(url.host, 'www.mercadopago.com.ar');
    });

    test('checkout sin url en la respuesta es un error de formato', () async {
      final service = HttpCheckoutService(clientWith((_) async => json({'ok': true})));
      expect(service.createCheckout([CartItem(product: testProduct())]),
          throwsA(isA<DataFormatException>()));
    });

    final historyDay = {
      'date': '2026-11-23',
      'totalSales': 1,
      'totalAmount': 4000,
      'sales': [
        {
          'id': 180006,
          'total': '4000',
          'status': 'PAID',
          'createdAt': '2026-11-23T12:00:00.000Z',
          'items': [
            {
              'id': 1,
              'quantity': 2,
              'priceAtSale': '2000',
              'saleId': 180006,
              'productId': 1,
              'product': {'id': 1, 'code': '7791813888468', 'name': 'Galletitas Oreo'},
            }
          ],
          'payment': {
            'id': 1,
            'providerPaymentId': '123',
            'amount': '4000',
            'paymentMethod': 'visa',
            'saleId': 180006,
            'createdAt': '2026-11-23T12:05:00.000Z',
          },
        }
      ],
    };

    test('GET /sales/history acepta {"history": [...]} (lo que devuelve el backend)', () async {
      final source = HttpSalesDataSource(clientWith((_) async => json({'history': [historyDay]})));
      final sales = await source.fetchSales();

      expect(requests.single.url.path, '/sales/history');
      expect(sales, hasLength(1));
      expect(sales.single.id, 180006);
      expect(sales.single.paymentMethod, 'visa');
      expect(sales.single.date.toUtc(), DateTime.utc(2026, 11, 23, 12, 5));
      expect(sales.single.items.single.unitPrice, 2000);
      expect(sales.single.items.single.productName, 'Galletitas Oreo');
    });

    test('GET /sales/history tambien acepta una lista suelta (como dice el PDF)', () async {
      final source = HttpSalesDataSource(clientWith((_) async => json([historyDay])));
      expect(await source.fetchSales(), hasLength(1));
    });

    test('una venta rota se ignora sin tirar abajo el historial', () async {
      final broken = {
        'date': '2026-11-23',
        'sales': [
          {'id': 1, 'items': []},
          ...(historyDay['sales'] as List),
        ],
      };
      final source = HttpSalesDataSource(clientWith((_) async => json({'history': [broken]})));
      expect((await source.fetchSales()).map((s) => s.id), [180006]);
    });
  });

  group('estadisticas con ventas reales', () {
    test('usan el precio y nombre de la venta aunque el producto cambie o se oculte', () {
      final now = DateTime(2026, 11, 23, 18);
      final stats = StatsRepository.buildStats(
        now: now,
        // El producto "OREO" cambio de precio y "VIEJO" ya no esta en el catalogo.
        products: [testProduct(code: 'OREO', name: 'Oreo nuevo', price: 9999)],
        sales: [
          Sale(
            id: 1,
            date: DateTime(2026, 11, 23, 12),
            paymentMethod: 'visa',
            items: const [
              SaleItem(productCode: 'OREO', quantity: 2, productName: 'Oreo', unitPrice: 2000),
              SaleItem(productCode: 'VIEJO', quantity: 1, productName: 'Viejo', unitPrice: 500),
            ],
          ),
        ],
      );

      expect(stats.totalSales, 4500, reason: '2×2000 + 1×500, no el precio actual');
      expect(stats.unitsSold, 3);
      expect(stats.topProducts.map((p) => p.product.name), ['Oreo nuevo', 'Viejo']);
      expect(stats.topProducts.first.revenue, 4000);
      expect(stats.todaySales, 4500);
    });
  });

  test('Product.fromJson lee isActive y asume activo si falta', () {
    expect(Product.fromJson(_oreo).isActive, isTrue);
    expect(Product.fromJson({..._oreo, 'isActive': false}).isActive, isFalse);
    expect(Product.fromJson({..._oreo}..remove('isActive')).isActive, isTrue);
  });
}
