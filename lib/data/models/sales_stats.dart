import 'package:zapi/data/models/product.dart';

/// Venta ya resuelta contra los productos reales (para el historial).
class SaleSummary {
  final int id;
  final DateTime date;
  final String paymentMethod;
  final int itemsCount;
  final double total;

  const SaleSummary({
    required this.id,
    required this.date,
    required this.paymentMethod,
    required this.itemsCount,
    required this.total,
  });
}

/// Unidades e ingresos acumulados de un producto en el periodo.
class ProductSales {
  final Product product;
  final int units;
  final double revenue;

  const ProductSales({
    required this.product,
    required this.units,
    required this.revenue,
  });
}

/// Ventas de un dia calendario.
class DailySales {
  final DateTime day;
  final double total;
  final int orders;

  const DailySales({required this.day, required this.total, required this.orders});
}

/// Todas las metricas del dashboard, calculadas a partir de UNA misma lista
/// de ventas para que tarjetas, graficos e historial siempre coincidan.
class SalesStats {
  /// Ventas por dia, de mas viejo a mas nuevo. El ultimo es "hoy".
  final List<DailySales> daily;

  /// Productos vendidos en el periodo, de mayor a menor cantidad.
  final List<ProductSales> topProducts;

  /// Ventas del periodo, de la mas reciente a la mas vieja.
  final List<SaleSummary> sales;

  const SalesStats({
    required this.daily,
    required this.topProducts,
    required this.sales,
  });

  int get totalOrders => sales.length;

  double get totalSales => sales.fold(0, (sum, sale) => sum + sale.total);

  int get unitsSold => topProducts.fold(0, (sum, item) => sum + item.units);

  double get todaySales => daily.isEmpty ? 0 : daily.last.total;

  ProductSales? get bestSeller => topProducts.isEmpty ? null : topProducts.first;

  int unitsSoldOf(String productCode) {
    for (final item in topProducts) {
      if (item.product.code == productCode) return item.units;
    }
    return 0;
  }
}
