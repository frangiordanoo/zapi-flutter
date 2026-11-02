import 'package:flutter_test/flutter_test.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/data/models/cart_item.dart';
import 'package:zapi/data/models/order.dart';
import 'package:zapi/data/repositories/order_repository.dart';
import 'package:zapi/data/repositories/product_repository.dart';

import '../support/fakes.dart';

void main() {
  final now = DateTime(2026, 11, 2, 10, 30);

  late FakeProductService service;
  late ProductRepository products;
  late OrderRepository orders;

  final agua = testProduct(id: 1, code: 'A', name: 'Agua', price: 1500, stock: 10);
  final papas = testProduct(id: 2, code: 'B', name: 'Papas', price: 2200, stock: 2);

  setUp(() {
    service = FakeProductService([agua, papas]);
    products = ProductRepository(service);
    orders = OrderRepository(products, paymentDelay: Duration.zero, clock: () => now);
  });

  Future<void> expectRejected(List<CartItem> items, String message) async {
    await expectLater(
      orders.placeOrder(items: items, paymentMethod: 'Efectivo'),
      throwsA(isA<OrderValidationException>().having((e) => e.message, 'message', message)),
    );
    expect(orders.orders, isEmpty, reason: 'no se crea ninguna orden');
  }

  group('validaciones', () {
    test('rechaza un carrito vacio', () async {
      await expectRejected([], 'El carrito está vacío.');
    });

    test('rechaza cantidades invalidas', () async {
      await expectRejected(
        [CartItem(product: agua, quantity: 0)],
        'Cantidad inválida para "Agua".',
      );
    });

    test('rechaza un producto que ya no existe', () async {
      final fantasma = testProduct(id: 9, code: 'NOEXISTE', name: 'Fantasma');
      await expectRejected(
        [CartItem(product: fantasma)],
        '"Fantasma" ya no está disponible.',
      );
    });

    test('rechaza stock insuficiente y no toca el stock', () async {
      await expectRejected(
        [CartItem(product: papas, quantity: 3)],
        'Stock insuficiente de "Papas": quedan 2.',
      );
      expect((await products.findByCode('B'))?.stock, 2);
    });

    test('rechaza un producto sin stock', () async {
      service.products[1] = papas.copyWith(stock: 0);
      await expectRejected([CartItem(product: papas)], '"Papas" está sin stock.');
    });

    test('un error de red al validar se propaga y no crea la orden', () async {
      service.errorToThrow = const NetworkException();
      await expectLater(
        orders.placeOrder(items: [CartItem(product: agua)], paymentMethod: 'Efectivo'),
        throwsA(isA<NetworkException>()),
      );
      expect(orders.orders, isEmpty);
    });
  });

  group('compra exitosa', () {
    test('crea la orden con id, fecha, items, total y estado', () async {
      final order = await orders.placeOrder(
        items: [
          CartItem(product: agua, quantity: 2),
          CartItem(product: papas),
        ],
        paymentMethod: 'Tarjeta',
      );

      expect(order.id, 1001);
      expect(order.date, now);
      expect(order.status, OrderStatus.paid);
      expect(order.paymentMethod, 'Tarjeta');
      expect(order.items.map((i) => i.productCode), ['A', 'B']);
      expect(order.items.first.unitPrice, 1500);
      expect(order.items.first.quantity, 2);
      expect(order.items.first.subtotal, 3000);
      expect(order.total, 5200);
      expect(order.itemsCount, 3);
    });

    test('descuenta el stock de cada producto', () async {
      await orders.placeOrder(
        items: [CartItem(product: agua, quantity: 4), CartItem(product: papas)],
        paymentMethod: 'Efectivo',
      );

      expect((await products.findByCode('A'))?.stock, 6);
      expect((await products.findByCode('B'))?.stock, 1);
      expect((await products.getProducts()).map((p) => p.stock), [6, 1]);
    });

    test('la orden se puede consultar despues y los ids son incrementales', () async {
      final first = await orders.placeOrder(
        items: [CartItem(product: agua)],
        paymentMethod: 'Efectivo',
      );
      final second = await orders.placeOrder(
        items: [CartItem(product: agua)],
        paymentMethod: 'Efectivo',
      );

      expect(second.id, first.id + 1);
      expect(orders.getOrder(first.id), same(first));
      expect(orders.getOrder(9999), isNull);
      expect(orders.orders.map((o) => o.id), [1001, 1002]);
    });

    test('no permite vender mas de lo que hay en dos compras seguidas', () async {
      await orders.placeOrder(
        items: [CartItem(product: papas, quantity: 2)],
        paymentMethod: 'Efectivo',
      );

      await expectLater(
        orders.placeOrder(items: [CartItem(product: papas)], paymentMethod: 'Efectivo'),
        throwsA(isA<OrderValidationException>()
            .having((e) => e.message, 'message', '"Papas" está sin stock.')),
      );
      expect(orders.orders, hasLength(1));
    });

    test('la orden conserva el precio con el que se compro', () async {
      final order = await orders.placeOrder(
        items: [CartItem(product: agua)],
        paymentMethod: 'Efectivo',
      );
      await products.updateProduct(agua.copyWith(price: 9999));

      expect(order.items.first.unitPrice, 1500);
      expect(order.total, 1500);
    });
  });
}
