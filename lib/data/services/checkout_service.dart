import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/core/network/api_client.dart';
import 'package:zapi/data/models/cart_item.dart';

/// Inicia el pago de un carrito.
abstract class CheckoutService {
  /// `POST /sales/checkout`. El backend crea la venta en estado PENDING,
  /// calcula el total con los precios de su base de datos y devuelve la URL
  /// de Mercado Pago (Checkout Pro) a la que hay que llevar al cliente.
  ///
  /// Errores utiles (mensaje listo para mostrar): 404 "Uno o más productos
  /// no existen", 409 "Stock insuficiente para <producto>.".
  Future<Uri> createCheckout(List<CartItem> items);
}

class HttpCheckoutService implements CheckoutService {
  HttpCheckoutService(this._api);

  final ApiClient _api;

  @override
  Future<Uri> createCheckout(List<CartItem> items) async {
    final json = await _api.postJson('/sales/checkout', {
      'cart': [
        for (final item in items)
          {'productId': item.product.id, 'quantity': item.quantity},
      ],
    });

    final url = json is Map ? json['url'] : null;
    final uri = url is String ? Uri.tryParse(url) : null;
    if (uri == null || !uri.hasScheme) {
      throw const DataFormatException('El servidor no devolvió el link de pago.');
    }
    return uri;
  }
}
