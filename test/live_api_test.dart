import 'package:flutter_test/flutter_test.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/core/network/api_client.dart';
import 'package:zapi/core/network/session_store.dart';
import 'package:zapi/data/models/cart_item.dart';
import 'package:zapi/data/models/sales_history_day.dart';
import 'package:zapi/data/services/auth_service.dart';
import 'package:zapi/data/services/checkout_service.dart';
import 'package:zapi/data/services/http_product_service.dart';
import 'package:zapi/data/services/http_sales_data_source.dart';

import 'support/fakes.dart';

/// Pruebas contra el backend REAL (`https://zapi-rqos.onrender.com`).
///
/// Son de SOLO LECTURA: no crean, editan ni borran nada (ni ventas ni
/// productos). Estan apagadas por defecto para que `flutter test` no dependa
/// de internet; se encienden con:
///
///     flutter test test/live_api_test.dart --dart-define=ZAPI_LIVE=true
///
/// Render (plan gratis) duerme el servidor: la primera llamada puede tardar
/// mas de 40 segundos y fallar por timeout; si pasa, reintentar.
const _live = bool.fromEnvironment('ZAPI_LIVE');

void main() {
  late SessionStore session;
  late ApiClient api;

  setUp(() {
    session = SessionStore();
    api = ApiClient(session: session);
  });

  group('API real (solo lectura)', skip: _live ? null : 'Definí --dart-define=ZAPI_LIVE=true', () {
    test('GET /products devuelve productos validos y activos', () async {
      final products = await HttpProductService(api).getProducts();

      expect(products, isNotEmpty);
      for (final p in products) {
        expect(p.id, greaterThan(0));
        expect(p.code, isNotEmpty);
        expect(p.name, isNotEmpty);
        expect(p.price, greaterThan(0), reason: '${p.name} tiene precio invalido');
        expect(p.stock, greaterThanOrEqualTo(1), reason: 'el listado publico solo trae con stock');
        expect(p.isActive, isTrue);
      }
    });

    test('GET /products/:code encuentra uno existente y da null si no existe', () async {
      final service = HttpProductService(api);
      final first = (await service.getProducts()).first;

      final found = await service.getProductByCode(first.code);
      expect(found?.code, first.code);
      expect(found?.name, first.name);

      expect(await service.getProductByCode('NO-EXISTE-ZZ-123'), isNull);
    });

    test('GET /sales/history se entiende y se agrupa por dia', () async {
      final sales = await HttpSalesDataSource(api).fetchSales();

      for (final sale in sales) {
        expect(sale.items, isNotEmpty);
        expect(sale.total, greaterThan(0));
        for (final item in sale.items) {
          expect(item.productName, isNotNull, reason: 'el historial trae el nombre del producto');
          expect(item.unitPrice, greaterThan(0));
          expect(item.quantity, greaterThan(0));
        }
      }

      final days = SalesHistoryDay.group(sales);
      expect(days.fold<int>(0, (n, d) => n + d.totalSales), sales.length);
      for (var i = 1; i < days.length; i++) {
        expect(days[i - 1].day.isAfter(days[i].day), isTrue, reason: 'dias del mas nuevo al mas viejo');
      }
    });

    test('login con credenciales incorrectas: 401 con el mensaje del backend', () async {
      await expectLater(
        HttpAuthService(api).login('usuario-que-no-existe-zz', 'x'),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 401)
            .having((e) => e.message, 'message', 'Usuario o contraseña incorrectos')),
      );
    });

    test('rutas de admin sin token: 401, y no queda ninguna sesion', () async {
      await expectLater(
        HttpProductService(api).getAllProducts(),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401)),
      );
      expect(session.hasToken, isFalse);
    });

    test('checkout con un producto inexistente: 404 (no crea ninguna venta)', () async {
      await expectLater(
        HttpCheckoutService(api).createCheckout([
          CartItem(product: testProduct(id: 999999999, code: 'NO-EXISTE')),
        ]),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 404)
            .having((e) => e.message, 'message', 'Uno o más productos no existen')),
      );
    });
  });
}
