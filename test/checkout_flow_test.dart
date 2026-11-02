import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/router/app_router.dart';
import 'package:zapi/data/models/product.dart';
import 'package:zapi/data/repositories/order_repository.dart';
import 'package:zapi/data/repositories/product_repository.dart';
import 'package:zapi/features/client/checkout/client_checkout_screen.dart';
import 'package:zapi/state/cart_controller.dart';
import 'package:zapi/state/order_controller.dart';
import 'package:zapi/state/product_catalog.dart';

import 'support/fakes.dart';

void main() {
  late FakeProductService service;
  late ProductRepository productRepository;
  late CartController cart;

  final agua = testProduct(id: 1, code: 'A', name: 'Agua mineral', price: 1500, stock: 5);

  setUp(() {
    service = FakeProductService([agua]);
    productRepository = ProductRepository(service);
    cart = CartController();
  });

  Future<void> pumpCheckout(WidgetTester tester) async {
    final catalog = ProductCatalog(productRepository)..load();
    final orderRepository = OrderRepository(
      productRepository,
      paymentDelay: const Duration(milliseconds: 300),
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: cart),
          ChangeNotifierProvider.value(value: catalog),
          ChangeNotifierProvider(create: (_) => OrderController(orderRepository, catalog)),
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
  });

  testWidgets('con un carrito vacio no se puede confirmar el pago', (tester) async {
    await pumpCheckout(tester);

    expect(find.text('Tu carrito está vacío.'), findsOneWidget);
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('confirmar el pago crea la orden, descuenta stock y vacia el carrito',
      (tester) async {
    cart.addProduct(agua);
    cart.increment(agua.id);
    await pumpCheckout(tester);

    await tester.tap(find.text('Confirmar pago'));
    await tester.pump();
    expect(find.text('Procesando pago…'), findsOneWidget);
    expect(find.text('Confirmar pago'), findsNothing, reason: 'no se puede tocar dos veces');

    await tester.pumpAndSettle();

    expect(find.text('¡Gracias por tu compra!'), findsOneWidget);
    expect(find.text('Pedido #1001'), findsOneWidget);
    expect(find.textContaining('Mercado Pago'), findsOneWidget);
    expect(find.textContaining('Pagado'), findsOneWidget);
    expect(find.text('x2 · \$1,500 c/u'), findsOneWidget);
    expect(cart.isEmpty, isTrue);
    expect((await productRepository.findByCode('A'))?.stock, 3);
  });

  testWidgets('sin stock suficiente muestra el error y conserva el carrito', (tester) async {
    final Product tooMany = agua.copyWith(stock: 1);
    service.products[0] = tooMany;
    cart.addProduct(agua);
    cart.increment(agua.id);

    await pumpCheckout(tester);
    await tester.tap(find.text('Confirmar pago'));
    await tester.pumpAndSettle();

    expect(find.text('Stock insuficiente de "Agua mineral": quedan 1.'), findsOneWidget);
    expect(find.text('¡Gracias por tu compra!'), findsNothing);
    expect(cart.totalItems, 2, reason: 'el carrito no se toca si la compra falla');
    expect((await productRepository.findByCode('A'))?.stock, 1);
  });
}
