import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/app.dart';
import 'package:zapi/core/constants/app_constants.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/data/repositories/product_repository.dart';
import 'package:zapi/features/client/product_list/client_product_list_screen.dart';
import 'package:zapi/state/cart_controller.dart';
import 'package:zapi/state/product_catalog.dart';

import 'support/fakes.dart';

void main() {
  testWidgets('La app arranca y muestra el Splash', (tester) async {
    await tester.pumpWidget(
      ZapiApp(productRepository: ProductRepository(FakeProductService([]))),
    );

    // El Splash muestra el logo de Zapi ("Z" + "API") apenas arranca,
    // antes de que dispare la navegacion automatica.
    expect(find.text('API'), findsOneWidget);
    expect(find.text('Z'), findsOneWidget);

    // El Splash programa un Timer para navegar solo despues de
    // AppConstants.splashTotalDuration. Avanzamos el reloj simulado del
    // test mas alla para que no quede ningun Timer pendiente.
    await tester.pump(
      AppConstants.splashTotalDuration + const Duration(milliseconds: 100),
    );
  });

  group('Flujo servicio -> repositorio -> estado -> pantalla', () {
    Widget appWith(FakeProductService service) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartController()),
          ChangeNotifierProvider(
            create: (_) => ProductCatalog(ProductRepository(service))..load(),
          ),
        ],
        child: const MaterialApp(home: ClientProductListScreen()),
      );
    }

    testWidgets('el listado muestra los productos que entrega la API', (tester) async {
      final service = FakeProductService([
        testProduct(id: 1, code: 'A', name: 'Agua mineral', price: 1500),
        testProduct(id: 2, code: 'B', name: 'Alfajor Jorgito', price: 900),
      ]);

      await tester.pumpWidget(appWith(service));
      await tester.pumpAndSettle();

      expect(find.text('Agua mineral'), findsOneWidget);
      expect(find.text('Alfajor Jorgito'), findsOneWidget);
      expect(service.getProductsCalls, 1);
    });

    testWidgets('si la API falla muestra el error y permite reintentar', (tester) async {
      final service = FakeProductService([
        testProduct(id: 1, code: 'A', name: 'Agua mineral'),
      ])..errorToThrow = const NetworkException();

      await tester.pumpWidget(appWith(service));
      await tester.pumpAndSettle();

      expect(find.text(const NetworkException().message), findsOneWidget);
      expect(find.text('Agua mineral'), findsNothing);

      service.errorToThrow = null;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(find.text('Agua mineral'), findsOneWidget);
    });
  });
}
