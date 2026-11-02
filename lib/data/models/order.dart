/// Estado de una orden. Hoy solo existe `paid` porque el pago es simulado y
/// una orden unicamente se crea cuando el pago sale bien.
enum OrderStatus {
  paid('Pagado');

  const OrderStatus(this.label);

  final String label;
}

/// Una linea de la orden. Guarda una copia (snapshot) de nombre y precio al
/// momento de comprar, asi la orden no cambia si despues cambia el producto.
class OrderItem {
  final String productCode;
  final String productName;
  final double unitPrice;
  final int quantity;

  const OrderItem({
    required this.productCode,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  double get subtotal => unitPrice * quantity;
}

/// Compra confirmada. El total siempre se calcula a partir de los items.
class Order {
  final int id;
  final DateTime date;
  final List<OrderItem> items;
  final String paymentMethod;
  final OrderStatus status;

  const Order({
    required this.id,
    required this.date,
    required this.items,
    required this.paymentMethod,
    required this.status,
  });

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);

  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);
}
