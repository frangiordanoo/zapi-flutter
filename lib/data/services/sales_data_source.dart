import 'package:zapi/data/models/sale.dart';

/// Fuente de ventas pagadas.
///
/// - `HttpSalesDataSource` (`GET /sales/history`): ventas reales, usadas por
///   el historial de ventas.
/// - `MockSalesDataSource`: ventas simuladas, usadas por las estadisticas
///   (el backend todavia no tiene estadisticas).
abstract class SalesDataSource {
  Future<List<Sale>> fetchSales();
}
