import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/data/models/cart_item.dart';
import 'package:zapi/data/models/order.dart';
import 'package:zapi/data/models/product.dart';
import 'package:zapi/data/repositories/product_repository.dart';

/// Crea y guarda las ordenes de compra.
///
/// El pago es una simulacion (no hay pasarela ni datos sensibles) y las
/// ordenes viven SOLO en memoria: el backend todavia no tiene endpoints de
/// ordenes ni de stock, asi que se pierden al cerrar la app y el descuento
/// de stock se aplica a traves de [ProductRepository.updateStock] (cambio
/// local de la sesion, igual que la edicion de productos del admin).
class OrderRepository {
  OrderRepository(
    this._products, {
    this.paymentDelay = const Duration(milliseconds: 1200),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final ProductRepository _products;
  final DateTime Function() _clock;

  /// Lo que "tarda" la simulacion de pago.
  final Duration paymentDelay;

  final List<Order> _orders = [];
  int _nextId = 1001;

  List<Order> get orders => List.unmodifiable(_orders);

  Order? getOrder(int id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  /// Valida el carrito, simula el pago y crea la orden descontando el stock.
  /// Lanza [OrderValidationException] si algo no se puede comprar; en ese
  /// caso no se crea ninguna orden ni se toca el stock.
  Future<Order> placeOrder({
    required List<CartItem> items,
    required String paymentMethod,
  }) async {
    if (items.isEmpty) {
      throw const OrderValidationException('El carrito está vacío.');
    }

    // Se consulta cada producto con GET /products/:code (y no el listado,
    // que la API corta en 20) para confirmar que existe y tiene stock.
    final current = <Product>[];
    for (final item in items) {
      final name = item.product.name;
      if (item.quantity <= 0) {
        throw OrderValidationException('Cantidad inválida para "$name".');
      }
      final product = await _products.findByCode(item.product.code);
      if (product == null) {
        throw OrderValidationException('"$name" ya no está disponible.');
      }
      if (product.stock <= 0) {
        throw OrderValidationException('"$name" está sin stock.');
      }
      if (item.quantity > product.stock) {
        throw OrderValidationException(
          'Stock insuficiente de "$name": quedan ${product.stock}.',
        );
      }
      current.add(product);
    }

    await Future<void>.delayed(paymentDelay);

    final order = Order(
      id: _nextId++,
      date: _clock(),
      paymentMethod: paymentMethod,
      status: OrderStatus.paid,
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

    for (var i = 0; i < items.length; i++) {
      await _products.updateStock(current[i], current[i].stock - items[i].quantity);
    }

    _orders.add(order);
    return order;
  }
}
