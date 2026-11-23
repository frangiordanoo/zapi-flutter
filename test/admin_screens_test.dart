import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/data/models/product.dart';
import 'package:zapi/data/models/sale.dart';
import 'package:zapi/features/admin/products/widgets/edit_product_dialog.dart';
import 'package:zapi/features/admin/sales_history/admin_sales_history_screen.dart';
import 'package:zapi/state/sales_history_controller.dart';

import 'support/fakes.dart';

Sale saleNow({int id = 180006, int quantity = 2, double price = 2000}) => Sale(
      id: id,
      date: DateTime.now(),
      paymentMethod: 'visa',
      items: [
        SaleItem(
          productCode: '7791813888468',
          quantity: quantity,
          productName: 'Galletitas Oreo',
          unitPrice: price,
        ),
      ],
    );

void main() {
  group('Historial de ventas (real)', () {
    Widget screenWith(FakeSalesSource source) => ChangeNotifierProvider(
          create: (_) => SalesHistoryController(source),
          child: const MaterialApp(home: AdminSalesHistoryScreen()),
        );

    testWidgets('muestra el dia, la venta con su hora, total y productos', (tester) async {
      await tester.pumpWidget(screenWith(FakeSalesSource([saleNow()])));
      await tester.pumpAndSettle();

      expect(find.text('Historial de ventas'), findsOneWidget);
      expect(find.text('Hoy'), findsOneWidget);
      expect(find.text('1 venta'), findsOneWidget);
      expect(find.text('Detalle de compra'), findsOneWidget);
      expect(find.text('Galletitas Oreo'), findsOneWidget);
      expect(find.text('2 x \$2,000'), findsOneWidget, reason: 'cantidad x precio de ese momento');
      expect(find.text('Total del día'), findsOneWidget);
      // $4,000 es el total de la venta y tambien el total del dia.
      expect(find.text('\$4,000'), findsNWidgets(2));
    });

    testWidgets('dos ventas el mismo dia: "2 ventas" y el total del dia las suma',
        (tester) async {
      await tester.pumpWidget(screenWith(FakeSalesSource([
        saleNow(id: 1, quantity: 1, price: 1000),
        saleNow(id: 2, quantity: 1, price: 800),
      ])));
      await tester.pumpAndSettle();

      expect(find.text('2 ventas'), findsOneWidget);
      expect(find.text('\$1,800'), findsOneWidget, reason: 'total del dia');
    });

    testWidgets('sin ventas muestra el mensaje vacio', (tester) async {
      await tester.pumpWidget(screenWith(FakeSalesSource([])));
      await tester.pumpAndSettle();

      expect(find.text('Todavía no hay ventas registradas.'), findsOneWidget);
    });

    testWidgets('si falla muestra el error y permite reintentar', (tester) async {
      final source = FakeSalesSource([saleNow()])..errorToThrow = const NetworkException();
      await tester.pumpWidget(screenWith(source));
      await tester.pumpAndSettle();

      expect(find.textContaining('No pudimos cargar el historial de ventas'), findsOneWidget);
      expect(find.text('Galletitas Oreo'), findsNothing);

      source.errorToThrow = null;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(find.text('Galletitas Oreo'), findsOneWidget);
    });

    testWidgets('se recarga cada vez que se entra a la pantalla', (tester) async {
      final source = FakeSalesSource([saleNow()]);
      await tester.pumpWidget(screenWith(source));
      await tester.pumpAndSettle();

      expect(source.fetchCalls, 1);
    });
  });

  group('Editar producto (validaciones del backend)', () {
    final product = testProduct(code: 'A', name: 'Agua mineral', price: 1500);
    Product? result;
    var dismissed = false;

    Future<void> openDialog(WidgetTester tester) async {
      result = null;
      dismissed = false;
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showDialog<Product>(
                context: context,
                builder: (_) => EditProductDialog(product: product),
              );
              dismissed = true;
            },
            child: const Text('abrir'),
          ),
        ),
      ));
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
    }

    Future<void> fill(WidgetTester tester, {String? name, String? price}) async {
      final fields = find.byType(TextFormField);
      if (name != null) await tester.enterText(fields.at(0), name);
      if (price != null) await tester.enterText(fields.at(1), price);
    }

    testWidgets('un nombre de 1 caracter se rechaza y el dialogo sigue abierto',
        (tester) async {
      await openDialog(tester);
      await fill(tester, name: 'a');
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();

      expect(find.text('El nombre debe tener al menos 2 caracteres'), findsOneWidget);
      expect(dismissed, isFalse);
    });

    testWidgets('un nombre de mas de 100 caracteres se rechaza', (tester) async {
      await openDialog(tester);
      await fill(tester, name: 'a' * 101);
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();

      expect(find.text('El nombre no puede superar los 100 caracteres'), findsOneWidget);
      expect(dismissed, isFalse);
    });

    testWidgets('precio 0, negativo o no numerico se rechaza', (tester) async {
      await openDialog(tester);

      await fill(tester, price: '0');
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();
      expect(find.text('El precio debe ser mayor que 0'), findsOneWidget);

      await fill(tester, price: '-5');
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();
      expect(find.text('El precio debe ser mayor que 0'), findsOneWidget);

      await fill(tester, price: 'abc');
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();
      expect(find.text('El precio debe ser un número'), findsOneWidget);

      expect(dismissed, isFalse, reason: 'nunca se cierra con datos invalidos');
    });

    testWidgets('con datos validos devuelve el producto editado (coma decimal incluida)',
        (tester) async {
      await openDialog(tester);
      await fill(tester, name: '  Agua con gas  ', price: '1999,5');
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
      expect(result?.name, 'Agua con gas');
      expect(result?.price, 1999.5);
      expect(result?.code, 'A', reason: 'el codigo no se puede cambiar');
      expect(result?.stock, product.stock, reason: 'el stock no se toca');
    });

    testWidgets('cancelar no devuelve nada', (tester) async {
      await openDialog(tester);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
      expect(result, isNull);
    });
  });
}
