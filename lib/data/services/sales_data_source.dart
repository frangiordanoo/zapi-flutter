import 'package:zapi/data/models/sale.dart';

/// Fuente de ventas. Hoy no existe un endpoint de ventas, asi que la unica
/// implementacion es `MockSalesDataSource`. El dia que exista, se crea una
/// `HttpSalesDataSource` y se cambia en `lib/app/app.dart`.
abstract class SalesDataSource {
  Future<List<Sale>> fetchSales();
}
