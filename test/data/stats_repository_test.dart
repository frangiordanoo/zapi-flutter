import 'package:flutter_test/flutter_test.dart';
import 'package:zapi/data/mocks/mock_sales_data_source.dart';
import 'package:zapi/data/models/product.dart';
import 'package:zapi/data/models/sale.dart';
import 'package:zapi/data/models/sales_stats.dart';
import 'package:zapi/data/repositories/product_repository.dart';
import 'package:zapi/data/repositories/stats_repository.dart';

import '../support/fakes.dart';

void main() {
  final now = DateTime(2026, 10, 29, 15, 30);

  final products = [
    testProduct(id: 1, code: 'A', name: 'Alfa', price: 1000),
    testProduct(id: 2, code: 'B', name: 'Beta', price: 500),
  ];

  Sale sale(int id, int daysAgo, List<(String, int)> lines) => Sale(
        id: id,
        date: DateTime(now.year, now.month, now.day - daysAgo, 12),
        paymentMethod: 'Efectivo',
        items: [for (final (c, q) in lines) SaleItem(productCode: c, quantity: q)],
      );

  group('buildStats', () {
    test('calcula totales, unidades y mas vendido a partir de las ventas', () {
      final stats = StatsRepository.buildStats(
        sales: [
          sale(1, 0, [('A', 2), ('B', 1)]), // 2500
          sale(2, 1, [('B', 4)]), // 2000
          sale(3, 3, [('A', 1)]), // 1000
        ],
        products: products,
        now: now,
      );

      expect(stats.totalOrders, 3);
      expect(stats.totalSales, 5500);
      expect(stats.todaySales, 2500);
      expect(stats.unitsSold, 8);
      expect(stats.bestSeller?.product.code, 'B');
      expect(stats.unitsSoldOf('A'), 3);
      expect(stats.unitsSoldOf('B'), 5);
      expect(stats.unitsSoldOf('NOEXISTE'), 0);
    });

    test('todas las vistas suman lo mismo (coherencia)', () {
      final stats = StatsRepository.buildStats(
        sales: [
          sale(1, 0, [('A', 2)]),
          sale(2, 2, [('B', 3)]),
          sale(3, 6, [('A', 1), ('B', 1)]),
        ],
        products: products,
        now: now,
      );

      final byDay = stats.daily.fold<double>(0, (s, d) => s + d.total);
      final byProduct = stats.topProducts.fold<double>(0, (s, p) => s + p.revenue);
      final bySale = stats.sales.fold<double>(0, (s, v) => s + v.total);
      final itemsInHistory = stats.sales.fold<int>(0, (s, v) => s + v.itemsCount);

      expect(byDay, stats.totalSales);
      expect(byProduct, stats.totalSales);
      expect(bySale, stats.totalSales);
      expect(itemsInHistory, stats.unitsSold);
      expect(stats.daily.fold<int>(0, (s, d) => s + d.orders), stats.totalOrders);
    });

    test('daily tiene 7 dias consecutivos y termina en hoy', () {
      final stats = StatsRepository.buildStats(sales: [], products: products, now: now);

      expect(stats.daily, hasLength(7));
      expect(stats.daily.last.day, DateTime(2026, 10, 29));
      expect(stats.daily.first.day, DateTime(2026, 10, 23));
      expect(stats.totalSales, 0);
      expect(stats.bestSeller, isNull);
    });

    test('ignora productos que ya no existen en la API sin inventarlos', () {
      final stats = StatsRepository.buildStats(
        sales: [
          sale(1, 0, [('A', 1), ('FANTASMA', 5)]),
          sale(2, 1, [('FANTASMA', 3)]),
        ],
        products: products,
        now: now,
      );

      expect(stats.totalOrders, 1, reason: 'la venta sin lineas validas se descarta');
      expect(stats.unitsSold, 1);
      expect(stats.totalSales, 1000);
      expect(stats.topProducts.map((p) => p.product.code), ['A']);
    });

    test('ignora ventas fuera de los ultimos 7 dias', () {
      final stats = StatsRepository.buildStats(
        sales: [
          sale(1, 7, [('A', 1)]),
          sale(2, 0, [('B', 1)]),
        ],
        products: products,
        now: now,
      );
      expect(stats.totalOrders, 1);
      expect(stats.totalSales, 500);
    });

    test('el historial va de la venta mas reciente a la mas vieja', () {
      final stats = StatsRepository.buildStats(
        sales: [
          sale(1, 5, [('A', 1)]),
          sale(2, 0, [('A', 1)]),
          sale(3, 2, [('A', 1)]),
        ],
        products: products,
        now: now,
      );
      expect(stats.sales.map((s) => s.id), [2, 3, 1]);
    });
  });

  group('con los datos mock de ventas', () {
    // Productos reales de la API a los que referencian las ventas mock.
    const apiProducts = {
      '7909883138066': ('Agua mineral', 1500.0),
      '7798161902198': ('Papas Lays Clásicas', 2200.0),
      '7790387800142': ('Alfajor Jorgito', 900.0),
      '7790580144364': ('Chocolate Milka', 2500.0),
      '7791813888468': ('Galletitas Oreo', 1800.0),
      '7790150260661': ('Agua Villavicencio 500ml', 1200.0),
      '7790150101773': ('Cafe instantaneo la virginia 100g', 1200.0),
      '7790710334603': ('Yerba mate CBSe guarana 500g', 3200.0),
      '7790040719804': ('Galletitas Rex Sabor Original 125g', 3200.0),
      '7622201735883': ('Galletas Pepitos', 1200.0),
      '7622201735258': ('Galletas Oreo', 1200.0),
      '7793253006792': ('Off', 1200.0),
      '7791520009712': ('Talco', 1000.0),
    };

    final catalog = <Product>[
      for (final (index, entry) in apiProducts.entries.indexed)
        testProduct(
          id: index + 1,
          code: entry.key,
          name: entry.value.$1,
          price: entry.value.$2,
        ),
    ];

    Future<SalesStats> statsAt(DateTime at) {
      final repo = StatsRepository(
        salesSource: MockSalesDataSource(clock: () => at, latency: Duration.zero),
        productRepository: ProductRepository(FakeProductService(catalog)),
        clock: () => at,
      );
      return repo.getStats();
    }

    test('tienen volumen bajo y creible', () async {
      final stats = await statsAt(DateTime(2026, 10, 29, 15, 30));

      expect(stats.totalOrders, inInclusiveRange(10, 25));
      expect(stats.unitsSold, lessThan(60));
      expect(stats.totalSales, lessThan(150000));
      for (final day in stats.daily) {
        expect(day.orders, lessThanOrEqualTo(4));
      }
    });

    test('varian entre dias y entre productos', () async {
      final stats = await statsAt(DateTime(2026, 10, 29, 15, 30));

      expect(stats.daily.map((d) => d.total).toSet().length, greaterThan(3));
      expect(stats.topProducts.map((p) => p.units).toSet().length, greaterThan(2));
    });

    test('ninguna venta cae en el futuro, a cualquier hora del dia', () async {
      for (final at in [
        DateTime(2026, 10, 29, 0, 10),
        DateTime(2026, 10, 29, 9, 0),
        DateTime(2026, 10, 29, 23, 59),
      ]) {
        final stats = await statsAt(at);
        expect(stats.sales.every((s) => !s.date.isAfter(at)), isTrue, reason: '$at');
        expect(stats.totalOrders, 15, reason: 'siempre entran las 15 ventas: $at');
      }
    });

    test('el total de hoy coincide con la suma de las ventas de hoy', () async {
      final at = DateTime(2026, 10, 29, 15, 30);
      final stats = await statsAt(at);
      final todaySum = stats.sales
          .where((s) => s.date.day == at.day)
          .fold<double>(0, (sum, s) => sum + s.total);

      expect(stats.todaySales, todaySum);
    });
  });
}
