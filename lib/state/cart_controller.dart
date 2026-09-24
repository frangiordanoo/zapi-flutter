import 'package:flutter/foundation.dart';
import 'package:zapi/models/cart_item.dart';
import 'package:zapi/models/product.dart';

/// Estado del carrito, compartido entre Client Home/Cart, Scanner y
/// Product List.
///
/// Es un simple `ChangeNotifier` expuesto con `provider` desde la raiz de
/// la app (ver lib/app/app.dart), asi que cualquier pantalla puede leerlo
/// con `context.watch<CartController>()` (para escuchar cambios y
/// redibujarse) o `context.read<CartController>()` (para solo llamar un
/// metodo, sin escuchar).
///
/// Si en el futuro el equipo decide migrar a Riverpod/Bloc, la logica de
/// aca adentro se puede mover casi tal cual: lo importante es que las
/// pantallas nunca manipulan la lista de items directamente, siempre
/// pasan por estos metodos.
class CartController extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  double get total => _items.fold(0, (sum, item) => sum + item.subtotal);

  /// Agrega un producto al carrito. Si ya estaba, le suma 1 a la cantidad
  /// en vez de duplicar la fila.
  void addProduct(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index == -1) {
      _items.add(CartItem(product: product));
    } else {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + 1,
      );
    }
    notifyListeners();
  }

  void increment(int productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(
      quantity: _items[index].quantity + 1,
    );
    notifyListeners();
  }

  void decrement(int productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index == -1) return;
    final newQuantity = _items[index].quantity - 1;
    if (newQuantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: newQuantity);
    }
    notifyListeners();
  }

  void removeProduct(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  bool contains(int productId) {
    return _items.any((item) => item.product.id == productId);
  }

  /// Vacia el carrito. Se va a usar cuando se confirme un pago real.
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
