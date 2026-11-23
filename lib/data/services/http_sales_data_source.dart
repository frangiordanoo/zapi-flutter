import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/core/network/api_client.dart';
import 'package:zapi/data/models/sale.dart';
import 'package:zapi/data/services/sales_data_source.dart';

/// [SalesDataSource] real: `GET /sales/history`.
///
/// El backend devuelve `{"history": [{"date", "totalSales", "totalAmount",
/// "sales": [...]}]}` (la documentacion en PDF lo muestra como lista suelta;
/// se aceptan ambas formas). Solo trae ventas PAGADAS, agrupadas por dia.
/// Aca se aplana a una lista de [Sale]; los totales se recalculan despues
/// en `StatsRepository` a partir de las mismas lineas.
class HttpSalesDataSource implements SalesDataSource {
  HttpSalesDataSource(this._api);

  final ApiClient _api;

  static const String defaultPaymentMethod = 'Mercado Pago';

  @override
  Future<List<Sale>> fetchSales() async {
    final json = await _api.getJson('/sales/history');
    final days = json is Map ? json['history'] : json;
    if (days is! List) {
      throw const DataFormatException('El historial de ventas tiene un formato inesperado.');
    }

    final sales = <Sale>[];
    for (final day in days) {
      if (day is! Map || day['sales'] is! List) continue;
      for (final raw in day['sales'] as List) {
        final sale = raw is Map<String, dynamic> ? _parseSale(raw) : null;
        if (sale != null) sales.add(sale);
      }
    }
    return sales;
  }

  /// Devuelve `null` si la venta esta rota (no tira abajo todo el historial).
  Sale? _parseSale(Map<String, dynamic> json) {
    final id = json['id'];
    final payment = json['payment'];

    // La fecha que cuenta es la del pago; si falta, la de creacion.
    final rawDate = (payment is Map ? payment['createdAt'] : null) ?? json['createdAt'];
    final date = rawDate is String ? DateTime.tryParse(rawDate)?.toLocal() : null;
    if (id is! num || date == null || json['items'] is! List) return null;

    final items = <SaleItem>[];
    for (final raw in json['items'] as List) {
      if (raw is! Map) continue;
      final product = raw['product'];
      final code = product is Map ? product['code']?.toString() : null;
      final quantity = raw['quantity'];
      final price = double.tryParse(raw['priceAtSale']?.toString() ?? '');
      if (code == null || quantity is! num || price == null) continue;
      items.add(SaleItem(
        productCode: code,
        quantity: quantity.toInt(),
        productName: product is Map ? product['name']?.toString() : null,
        unitPrice: price,
      ));
    }
    if (items.isEmpty) return null;

    final method = payment is Map ? payment['paymentMethod']?.toString() : null;
    return Sale(
      id: id.toInt(),
      date: date,
      paymentMethod: (method == null || method.isEmpty) ? defaultPaymentMethod : method,
      items: items,
    );
  }
}
