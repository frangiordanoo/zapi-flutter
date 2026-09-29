/// Representa una venta ya realizada (para el historial de ventas del
/// administrador). Es un modelo simple, pensado solo para mostrar datos
/// mock; cuando exista backend, esto probablemente venga de un
/// `SaleService` que consulte un endpoint real de ventas.
class Sale {
  final int id;
  final DateTime date;
  final int itemsCount;
  final double total;
  final String paymentMethod;

  const Sale({
    required this.id,
    required this.date,
    required this.itemsCount,
    required this.total,
    required this.paymentMethod,
  });
}
