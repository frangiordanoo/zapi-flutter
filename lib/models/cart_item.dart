import 'package:zapi/models/product.dart';

/// Representa un producto dentro del carrito, con su cantidad.
///
/// Se usa tanto en la pantalla de Carrito como en Scanner y Product List
/// (las tres comparten el mismo `CartController`, ver lib/state/cart_controller.dart).
class CartItem {
  final Product product;
  final int quantity;

  const CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get subtotal => product.price * quantity;

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
