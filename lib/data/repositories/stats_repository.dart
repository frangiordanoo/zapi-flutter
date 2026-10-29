import 'package:zapi/data/models/product.dart';
import 'package:zapi/data/models/sale.dart';
import 'package:zapi/data/models/sales_stats.dart';
import 'package:zapi/data/repositories/product_repository.dart';
import 'package:zapi/data/services/sales_data_source.dart';

/// Arma las estadisticas del administrador combinando las ventas (hoy
/// simuladas) con los productos reales de la API.
///
/// Reglas:
/// - Nombre, precio y categoria salen SIEMPRE de la API; las ventas solo
///   referencian productos por `code`.
/// - Una linea de venta cuyo producto ya no existe en la API se ignora
///   (no se inventa un producto). Si una venta se queda sin lineas, se
///   descarta completa.
/// - Todas las metricas salen de la MISMA lista de ventas, asi que
///   totales, graficos e historial no pueden contradecirse.
/// - Es de solo lectura: no toca el stock ni escribe en la API.
class StatsRepository {
  StatsRepository({
    required SalesDataSource salesSource,
    required ProductRepository productRepository,
    DateTime Function()? clock,
  })  : _salesSource = salesSource,
        _productRepository = productRepository,
        _clock = clock ?? DateTime.now;

  final SalesDataSource _salesSource;
  final ProductRepository _productRepository;
  final DateTime Function() _clock;

  /// Cantidad de dias que cubren las estadisticas (hoy incluido).
  static const int periodDays = 7;

  Future<SalesStats> getStats() async {
    final products = await _productRepository.getProducts();
    final sales = await _salesSource.fetchSales();
    return buildStats(sales: sales, products: products, now: _clock());
  }

  static SalesStats buildStats({
    required List<Sale> sales,
    required List<Product> products,
    required DateTime now,
  }) {
    final productsByCode = {for (final p in products) p.code: p};
    final today = DateTime(now.year, now.month, now.day);
    final firstDay = DateTime(today.year, today.month, today.day - (periodDays - 1));

    final summaries = <SaleSummary>[];
    final unitsByCode = <String, int>{};
    final revenueByCode = <String, double>{};
    final totalByDay = <DateTime, double>{};
    final ordersByDay = <DateTime, int>{};

    for (final sale in sales) {
      final day = DateTime(sale.date.year, sale.date.month, sale.date.day);
      if (day.isBefore(firstDay) || day.isAfter(today)) continue;

      var itemsCount = 0;
      var total = 0.0;
      for (final item in sale.items) {
        final product = productsByCode[item.productCode];
        if (product == null || item.quantity <= 0) continue;
        final lineTotal = product.price * item.quantity;
        itemsCount += item.quantity;
        total += lineTotal;
        unitsByCode.update(product.code, (u) => u + item.quantity,
            ifAbsent: () => item.quantity);
        revenueByCode.update(product.code, (r) => r + lineTotal,
            ifAbsent: () => lineTotal);
      }
      if (itemsCount == 0) continue;

      summaries.add(SaleSummary(
        id: sale.id,
        date: sale.date,
        paymentMethod: sale.paymentMethod,
        itemsCount: itemsCount,
        total: total,
      ));
      totalByDay.update(day, (t) => t + total, ifAbsent: () => total);
      ordersByDay.update(day, (o) => o + 1, ifAbsent: () => 1);
    }

    summaries.sort((a, b) => b.date.compareTo(a.date));

    final daily = [
      for (var i = periodDays - 1; i >= 0; i--)
        () {
          final day = DateTime(today.year, today.month, today.day - i);
          return DailySales(
            day: day,
            total: totalByDay[day] ?? 0,
            orders: ordersByDay[day] ?? 0,
          );
        }(),
    ];

    final topProducts = [
      for (final entry in unitsByCode.entries)
        ProductSales(
          product: productsByCode[entry.key]!,
          units: entry.value,
          revenue: revenueByCode[entry.key]!,
        ),
    ]..sort((a, b) {
        final byUnits = b.units.compareTo(a.units);
        return byUnits != 0 ? byUnits : a.product.name.compareTo(b.product.name);
      });

    return SalesStats(daily: daily, topProducts: topProducts, sales: summaries);
  }
}
