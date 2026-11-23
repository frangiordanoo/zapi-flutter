import 'package:flutter_test/flutter_test.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/data/models/cart_item.dart';
import 'package:zapi/data/models/order.dart';
import 'package:zapi/data/repositories/order_repository.dart';

import '../support/fakes.dart';

void main() {
  final now = DateTime(2026, 11, 2, 10, 30);
  final agua = testProduct(id: 1, code: 'A', name: 'Agua', price: 1500, stock: 10);
  final papas = testProduct(id: 2, code: 'B', name: 'Papas', price: 2200, stock: 2);

  late FakeCheckoutService service;
  late OrderRepository orders;

  setUp(() {
    service = FakeCheckoutService();
    orders = OrderRepository(service, clock: () => now);
  });

  test('rechaza un carrito vacio sin llamar al backend', () async {
    await expectLater(
      orders.startCheckout([]),
      throwsA(isA<OrderValidationException>()
          .having((e) => e.message, 'message', 'El carrito está vacío.')),
    );
    expect(service.lastItems, isNull);
  });

  test('rechaza cantidades invalidas sin llamar al backend', () async {
    await expectLater(
      orders.startCheckout([CartItem(product: agua, quantity: 0)]),
      throwsA(isA<OrderValidationException>()
          .having((e) => e.message, 'message', 'Cantidad inválida para "Agua".')),
    );
    expect(service.lastItems, isNull);
  });

  test('arma la orden pendiente con el link de Mercado Pago', () async {
    final order = await orders.startCheckout([
      CartItem(product: agua, quantity: 2),
      CartItem(product: papas),
    ]);

    expect(service.lastItems, hasLength(2));
    expect(order.checkoutUrl, FakeCheckoutService.link);
    expect(order.status, OrderStatus.pending);
    expect(order.paymentMethod, 'Mercado Pago');
    expect(order.date, now);
    expect(order.itemsCount, 3);
    expect(order.total, 1500 * 2 + 2200);
    expect(order.items.first.productName, 'Agua');
  });

  test('los errores del backend (stock insuficiente) se propagan', () async {
    service.errorToThrow = const ApiException(409, 'Stock insuficiente para Papas.');

    await expectLater(
      orders.startCheckout([CartItem(product: papas, quantity: 3)]),
      throwsA(isA<ApiException>()
          .having((e) => e.message, 'message', 'Stock insuficiente para Papas.')),
    );
  });
}
