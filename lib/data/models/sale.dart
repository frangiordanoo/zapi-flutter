/// Una linea de una venta: que producto (por su `code`, el identificador
/// estable de la API) y cuantas unidades.
class SaleItem {
  final String productCode;
  final int quantity;

  const SaleItem({required this.productCode, required this.quantity});
}

/// Una venta tal como la entregaria una fuente de ventas (hoy un mock,
/// manana un endpoint). No guarda precios ni nombres: eso se toma de los
/// productos reales de la API al armar las estadisticas.
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
}
