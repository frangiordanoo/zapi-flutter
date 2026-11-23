/// Una linea de una venta: que producto (por su `code`, el identificador
/// estable de la API) y cuantas unidades.
///
/// Las ventas reales (`GET /sales/history`) traen ademas el nombre y el
/// precio **al momento de la venta** ([productName], [unitPrice]); con eso
/// el historial no cambia si despues se edita el producto o se oculta. Las
/// ventas simuladas (mock) no los traen y se resuelven contra el catalogo.
class SaleItem {
  final String productCode;
  final int quantity;
  final String? productName;
  final double? unitPrice;

  const SaleItem({
    required this.productCode,
    required this.quantity,
    this.productName,
    this.unitPrice,
  });
}

/// Una venta pagada tal como la entrega una fuente de ventas (el endpoint
/// de historial, o el mock en tests).
class Sale {
  final int id;
  final DateTime date;
  final String paymentMethod;
  final List<SaleItem> items;

  const Sale({
    required this.id,
    required this.date,
    required this.paymentMethod,
    required this.items,
  });

  /// Total de la venta con los precios al momento de vender. Solo tiene
  /// sentido en ventas reales (las simuladas no traen [SaleItem.unitPrice]).
  double get total =>
      items.fold(0, (sum, item) => sum + item.quantity * (item.unitPrice ?? 0));
}
