import 'package:flutter/foundation.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/data/models/product.dart';
import 'package:zapi/data/repositories/product_repository.dart';

/// Estado del catalogo de productos, compartido por las pantallas de
/// cliente (listado, categorias, scanner) y de administrador (productos,
/// stock, notificaciones). Es un `ChangeNotifier` simple, igual que
/// `CartController`: las pantallas leen `products` / `isLoading` /
/// `errorMessage` y nunca hablan con la API directamente.
///
/// Si una recarga falla, se CONSERVAN los productos que ya estaban
/// cargados y se expone `errorMessage` para que la UI avise que pueden
/// estar desactualizados.
class ProductCatalog extends ChangeNotifier {
  ProductCatalog(this._repository);

  final ProductRepository _repository;

  List<Product> _products = [];
  bool isLoading = false;
  String? errorMessage;

  /// Productos del catalogo (los que devuelve la API, mas los cambios
  /// locales descritos en [ProductRepository]).
  List<Product> get products => List.unmodifiable(_products);

  bool _reloadQueued = false;

  /// Recarga el listado desde la API. Si ya hay una carga en curso, encola
  /// una recarga extra para no perder cambios hechos mientras tanto.
  Future<void> load() async {
    if (isLoading) {
      _reloadQueued = true;
      return;
    }
    isLoading = true;
    notifyListeners();
    try {
      do {
        _reloadQueued = false;
        try {
          _products = await _repository.getProducts();
          errorMessage = null;
        } on AppException catch (e) {
          errorMessage = e.message;
        }
      } while (_reloadQueued);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Busca un producto con `GET /products/:code`. Devuelve `null` si no
  /// existe; si falla la conexion lanza una [AppException].
  Future<Product?> findByCode(String code) => _repository.findByCode(code);

  /// Crea el producto en la API y recarga el listado completo (asi nunca
  /// quedan duplicados). Lanza [AppException] si la creacion falla.
  Future<void> addProduct(Product product) async {
    await _repository.createProduct(product);
    await load();
  }

  Future<void> updateProduct(Product product) async {
    await _repository.updateProduct(product);
    await load();
  }

  Future<void> deleteProduct(Product product) async {
    await _repository.deleteProduct(product);
    await load();
  }

  Future<void> updateStock(Product product, int newStock) async {
    await _repository.updateStock(product, newStock);
    await load();
  }
}
