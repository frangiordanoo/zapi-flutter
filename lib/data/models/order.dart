/// Estado de una orden desde el punto de vista de la app.
///
/// La app NUNCA puede confirmar un pago: eso lo hace el backend cuando
/// Mercado Pago le avisa por webhook (y recien ahi descuenta el stock y la
/// venta pasa a PAID). Volver de Mercado Pago a la app no prueba nada, por
/// eso la unica situacion que la app conoce es "pago iniciado".
enum OrderStatus {
  pending('Pendiente de pago');

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

/// Pago iniciado: el carrito que se mando al backend y el link de Mercado
/// Pago para completarlo. El total mostrado es informativo; el definitivo
/// lo calcula el backend con los precios de su base de datos.
class Order {
  final DateTime date;
  final List<OrderItem> items;
  final String paymentMethod;
  final OrderStatus status;
  final Uri checkoutUrl;

  const Order({
    required this.date,
    required this.items,
    required this.paymentMethod,
    required this.status,
    required this.checkoutUrl,
  });

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);

  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);
}
