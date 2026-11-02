import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/data/models/cart_item.dart';
import 'package:zapi/data/models/order.dart';
import 'package:zapi/data/repositories/order_repository.dart';
import 'package:zapi/state/product_catalog.dart';

/// Estado de la compra: expone si se esta procesando un pago y delega la
/// creacion de la orden en [OrderRepository]. Al terminar bien recarga el
/// catalogo para que las pantallas muestren el stock ya descontado.
///
/// No toca el carrito: quien confirma la compra lo vacia (ver
/// `ClientCheckoutScreen`).
class OrderController extends ChangeNotifier {
  OrderController(this._repository, this._catalog);

  final OrderRepository _repository;
  final ProductCatalog _catalog;

  bool isProcessing = false;

  List<Order> get orders => _repository.orders;

  Order? orderById(int id) => _repository.getOrder(id);

  /// Crea la orden. Lanza [AppException] si no se puede comprar.
  Future<Order> placeOrder({
    required List<CartItem> items,
    required String paymentMethod,
  }) async {
    if (isProcessing) {
      throw const OrderValidationException('Ya se está procesando el pago.');
    }
    isProcessing = true;
    notifyListeners();
    try {
      final order = await _repository.placeOrder(
        items: items,
        paymentMethod: paymentMethod,
      );
      unawaited(_catalog.load());
      return order;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }
}
