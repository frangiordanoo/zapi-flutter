import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/data/models/cart_item.dart';
import 'package:zapi/data/models/order.dart';
import 'package:zapi/data/services/checkout_service.dart';

/// Inicia el pago de un carrito contra el backend (Mercado Pago).
///
/// La validacion fuerte (productos existentes, stock suficiente, precios y
/// total) la hace el backend en `POST /sales/checkout`; aca solo se evitan
/// pedidos sin sentido y se arma el [Order] con el link de pago.
class OrderRepository {
  OrderRepository(this._service, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final CheckoutService _service;
  final DateTime Function() _clock;

  static const String paymentMethod = 'Mercado Pago';

  /// Lanza [OrderValidationException] si el carrito no se puede enviar, o la
  /// [AppException] del backend (stock insuficiente, red, etc.).
  Future<Order> startCheckout(List<CartItem> items) async {
    if (items.isEmpty) {
      throw const OrderValidationException('El carrito está vacío.');
    }
    for (final item in items) {
      if (item.quantity <= 0) {
        throw OrderValidationException('Cantidad inválida para "${item.product.name}".');
      }
    }

    final url = await _service.createCheckout(items);

    return Order(
      date: _clock(),
      paymentMethod: paymentMethod,
      status: OrderStatus.pending,
      checkoutUrl: url,
      items: [
        for (final item in items)
          OrderItem(
            productCode: item.product.code,
            productName: item.product.name,
            unitPrice: item.product.price,
            quantity: item.quantity,
          ),
      ],
    );
  }
}
