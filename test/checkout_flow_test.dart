import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/router/app_router.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/data/repositories/order_repository.dart';
import 'package:zapi/features/client/checkout/client_checkout_screen.dart';
import 'package:zapi/state/cart_controller.dart';
import 'package:zapi/state/order_controller.dart';

import 'support/fakes.dart';

void main() {
  late FakeCheckoutService checkout;
  late CartController cart;
  late List<Uri> opened;
  late bool canOpen;

  final agua = testProduct(id: 1, code: 'A', name: 'Agua mineral', price: 1500, stock: 5);

  setUp(() {
    checkout = FakeCheckoutService();
    cart = CartController();
    opened = [];
    canOpen = true;
  });

  Future<void> pumpCheckout(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: cart),
          ChangeNotifierProvider(
            create: (_) => OrderController(
              OrderRepository(checkout),
              opener: (url) async {
                opened.add(url);
                return canOpen;
              },
            ),
          ),
        ],
        child: const MaterialApp(
          home: ClientCheckoutScreen(),
          onGenerateRoute: AppRouter.generateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('el resumen muestra precio unitario, subtotal y total', (tester) async {
    cart.addProduct(agua);
    cart.increment(agua.id);

    await pumpCheckout(tester);

    expect(find.text('Agua mineral'), findsOneWidget);
    expect(find.text('x2 · \$1,500 c/u'), findsOneWidget);
    expect(find.text('\$3,000'), findsNWidgets(2), reason: 'subtotal y total');
    expect(find.text('Mercado Pago'), findsOneWidget);
  });

  testWidgets('con un carrito vacio no se puede pagar', (tester) async {
    await pumpCheckout(tester);

    expect(find.text('Tu carrito está vacío.'), findsOneWidget);
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('pagar abre Mercado Pago, vacia el carrito y muestra el pago en curso',
      (tester) async {
    cart.addProduct(agua);
    cart.increment(agua.id);
    await pumpCheckout(tester);

    await tester.tap(find.text('Pagar con Mercado Pago'));
    await tester.pumpAndSettle();

    expect(opened, [FakeCheckoutService.link]);
    expect(checkout.lastItems?.single.quantity, 2);
    expect(find.text('Completá tu pago'), findsOneWidget);
    expect(find.textContaining('Pendiente de pago'), findsOneWidget);
    expect(find.text('¡Gracias por tu compra!'), findsNothing,
        reason: 'la app no puede confirmar el pago');
    expect(find.text('x2 · \$1,500 c/u'), findsOneWidget);
    expect(cart.isEmpty, isTrue);
  });

  testWidgets('si el backend rechaza la compra muestra su mensaje y conserva el carrito',
      (tester) async {
    checkout.errorToThrow = const ApiException(409, 'Stock insuficiente para Agua mineral.');
    cart.addProduct(agua);
    cart.increment(agua.id);

    await pumpCheckout(tester);
    await tester.tap(find.text('Pagar con Mercado Pago'));
    await tester.pumpAndSettle();

    expect(find.text('Stock insuficiente para Agua mineral.'), findsOneWidget);
    expect(find.text('Completá tu pago'), findsNothing);
    expect(opened, isEmpty);
    expect(cart.totalItems, 2, reason: 'el carrito no se toca si la compra falla');
  });

  testWidgets('si no se puede abrir Mercado Pago conserva el carrito', (tester) async {
    canOpen = false;
    cart.addProduct(agua);
    await pumpCheckout(tester);

    await tester.tap(find.text('Pagar con Mercado Pago'));
    await tester.pumpAndSettle();

    expect(find.text('No se pudo abrir Mercado Pago.'), findsOneWidget);
    expect(cart.isEmpty, isFalse);
  });
}
