import 'package:flutter_test/flutter_test.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/data/models/sale.dart';
import 'package:zapi/data/models/sales_history_day.dart';
import 'package:zapi/state/sales_history_controller.dart';

import '../support/fakes.dart';

Sale sale(int id, DateTime date, {int quantity = 1, double price = 1000}) => Sale(
      id: id,
      date: date,
      paymentMethod: 'visa',
      items: [
        SaleItem(
          productCode: 'A',
          quantity: quantity,
          productName: 'Agua',
          unitPrice: price,
        ),
      ],
    );

void main() {
  group('Sale.total', () {
    test('suma cantidad x precio al momento de la venta', () {
      final s = Sale(
        id: 1,
        date: DateTime.utc(2026, 11, 23, 12),
        paymentMethod: 'visa',
        items: const [
          SaleItem(productCode: 'A', quantity: 2, unitPrice: 2000),
          SaleItem(productCode: 'B', quantity: 1, unitPrice: 500),
        ],
      );
      expect(s.total, 4500);
    });
  });

  group('SalesHistoryDay.group', () {
    test('agrupa por dia, del mas reciente al mas antiguo', () {
      final days = SalesHistoryDay.group([
        sale(1, DateTime.utc(2026, 11, 20, 15)),
        sale(2, DateTime.utc(2026, 11, 23, 15)),
        sale(3, DateTime.utc(2026, 11, 20, 18)),
      ]);

      expect(days.map((d) => d.day), [DateTime.utc(2026, 11, 23), DateTime.utc(2026, 11, 20)]);
      expect(days.map((d) => d.totalSales), [1, 2]);
    });

    test('dentro de un dia la venta mas reciente va primero', () {
      final days = SalesHistoryDay.group([
        sale(1, DateTime.utc(2026, 11, 20, 13)),
        sale(2, DateTime.utc(2026, 11, 20, 19)),
        sale(3, DateTime.utc(2026, 11, 20, 16)),
      ]);

      expect(days.single.sales.map((s) => s.id), [2, 3, 1]);
    });

    test('el dia se cuenta en hora de Argentina (UTC-3), no en UTC', () {
      final days = SalesHistoryDay.group([
        // 02:30 UTC del 24 = 23:30 del 23 en Argentina.
        sale(1, DateTime.utc(2026, 11, 24, 2, 30)),
        // 03:00 UTC del 24 = 00:00 del 24 en Argentina.
        sale(2, DateTime.utc(2026, 11, 24, 3, 0)),
      ]);

      expect(days.map((d) => d.day), [DateTime.utc(2026, 11, 24), DateTime.utc(2026, 11, 23)]);
      expect(days[0].sales.single.id, 2);
      expect(days[1].sales.single.id, 1);
    });

    test('el total del dia suma todas sus ventas', () {
      final day = SalesHistoryDay.group([
        sale(1, DateTime.utc(2026, 11, 20, 13), quantity: 2, price: 2000),
        sale(2, DateTime.utc(2026, 11, 20, 14), price: 800),
      ]).single;

      expect(day.totalSales, 2);
      expect(day.totalAmount, 4800);
    });

    test('sin ventas no hay dias', () {
      expect(SalesHistoryDay.group([]), isEmpty);
    });
  });

  group('etiquetas', () {
    // 24/11 12:00 en Argentina.
    final now = DateTime.utc(2026, 11, 24, 15);

    SalesHistoryDay dayOf(DateTime utc) => SalesHistoryDay.group([sale(1, utc)]).single;

    test('Hoy y Ayer', () {
      expect(dayOf(DateTime.utc(2026, 11, 24, 14)).label(now), 'Hoy');
      expect(dayOf(DateTime.utc(2026, 11, 23, 14)).label(now), 'Ayer');
    });

    test('otro dia: fecha completa en español', () {
      expect(dayOf(DateTime.utc(2026, 11, 20, 14)).label(now), '20 de noviembre de 2026');
      expect(dayOf(DateTime.utc(2026, 1, 5, 14)).label(now), '5 de enero de 2026');
    });

    test('Ayer tambien cruza el cambio de mes', () {
      final firstOfMonth = DateTime.utc(2026, 12, 1, 15);
      expect(dayOf(DateTime.utc(2026, 11, 30, 14)).label(firstOfMonth), 'Ayer');
    });

    test('la hora de la venta se muestra en hora de Argentina', () {
      expect(SalesHistoryDay.clock(DateTime.utc(2026, 11, 23, 12, 5)), '09:05');
      expect(SalesHistoryDay.clock(DateTime.utc(2026, 11, 24, 2, 30)), '23:30');
    });
  });

  group('SalesHistoryController', () {
    test('carga y agrupa las ventas', () async {
      final controller = SalesHistoryController(
        FakeSalesSource([sale(1, DateTime.utc(2026, 11, 20, 14))]),
      );

      expect(controller.days, isNull);
      await controller.load();

      expect(controller.days, hasLength(1));
      expect(controller.errorMessage, isNull);
      expect(controller.isLoading, isFalse);
    });

    test('si falla expone el mensaje y conserva lo cargado antes', () async {
      final source = FakeSalesSource([sale(1, DateTime.utc(2026, 11, 20, 14))]);
      final controller = SalesHistoryController(source);
      await controller.load();

      source.errorToThrow = const NetworkException();
      await controller.load();

      expect(controller.errorMessage, const NetworkException().message);
      expect(controller.days, hasLength(1), reason: 'no se pierde lo que ya se veia');
    });

    test('clear descarta los datos (al cerrar sesion)', () async {
      final controller = SalesHistoryController(
        FakeSalesSource([sale(1, DateTime.utc(2026, 11, 20, 14))]),
      );
      await controller.load();

      controller.clear();

      expect(controller.days, isNull);
    });
  });
}
