import 'package:flutter/foundation.dart';
import 'package:zapi/models/product.dart';
import 'package:zapi/services/product_service.dart';

/// Envuelve un [ProductService] y expone el catalogo de productos como
/// estado observable, para que tanto las pantallas de cliente
/// (Product List) como las de administrador (Products, Stock, Stock
/// Review, Add Product) muestren siempre la misma info y se actualicen
/// solas cuando algo cambia (por ejemplo: el admin borra un producto y
/// la lista del cliente deja de mostrarlo).
///
/// Igual que `CartController`, es un ChangeNotifier simple a proposito.
class ProductCatalog extends ChangeNotifier {
  ProductCatalog(this._service);

  final ProductService _service;

  List<Product> _products = [];
  bool isLoading = false;

  /// Productos visibles (no borrados). Es lo que deberian usar casi
  /// todas las pantallas.
  List<Product> get products => List.unmodifiable(_products);

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    _products = await _service.getProducts();
    isLoading = false;
    notifyListeners();
  }

  Future<Product?> findByCode(String code) {
    return _service.getProductByCode(code);
  }

  Future<void> addProduct(Product product) async {
    await _service.createProduct(product);
    await load();
  }

  Future<void> updateProduct(Product product) async {
    await _service.updateProduct(product);
    await load();
  }

  /// Soft delete: el producto deja de aparecer en `products`, pero no se
  /// borra de verdad (ver comentario en lib/models/product.dart).
  Future<void> softDeleteProduct(int id) async {
    await _service.deleteProduct(id);
    await load();
  }

  Future<void> updateStock(int id, int newStock) async {
    await _service.updateStock(id, newStock);
    await load();
  }
}
