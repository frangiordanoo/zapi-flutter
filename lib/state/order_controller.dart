import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/data/models/cart_item.dart';
import 'package:zapi/data/models/order.dart';
import 'package:zapi/data/repositories/order_repository.dart';

/// Abre una URL fuera de la app (el navegador / app de Mercado Pago).
/// Devuelve `false` si no se pudo abrir. Es inyectable para los tests.
typedef UrlOpener = Future<bool> Function(Uri url);

Future<bool> _openExternally(Uri url) =>
    launchUrl(url, mode: LaunchMode.externalApplication);

/// Estado de la compra: expone si se esta iniciando un pago, delega la
/// creacion del checkout en [OrderRepository] y abre Mercado Pago.
///
/// No toca el carrito: quien inicia la compra lo vacia (ver
/// `ClientCheckoutScreen`). Tampoco toca el stock: el backend lo descuenta
/// recien cuando Mercado Pago confirma el pago.
class OrderController extends ChangeNotifier {
  OrderController(this._repository, {UrlOpener? opener}) : _opener = opener ?? _openExternally;

  final OrderRepository _repository;
  final UrlOpener _opener;

  bool isProcessing = false;

  /// Crea el checkout y abre Mercado Pago. Lanza [AppException] si no se
  /// puede (stock insuficiente, sin conexion, no se pudo abrir el link...).
  Future<Order> startCheckout(List<CartItem> items) async {
    if (isProcessing) {
      throw const OrderValidationException('Ya se está iniciando el pago.');
    }
    isProcessing = true;
    notifyListeners();
    try {
      final order = await _repository.startCheckout(items);
      await openCheckout(order);
      return order;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  /// Vuelve a abrir el link de pago (por si el cliente cerro Mercado Pago).
  Future<void> openCheckout(Order order) async {
    bool opened;
    try {
      opened = await _opener(order.checkoutUrl);
    } catch (_) {
      opened = false;
    }
    if (!opened) {
      throw const OrderValidationException('No se pudo abrir Mercado Pago.');
    }
  }
}
