import 'package:flutter/foundation.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/data/models/product.dart';
import 'package:zapi/data/models/stock_review.dart';
import 'package:zapi/data/repositories/product_repository.dart';

/// Estado del catalogo de productos, compartido por las pantallas de
/// cliente (listado, categorias, scanner) y de administrador (productos,
/// stock, notificaciones). Es un `ChangeNotifier` simple, igual que
/// `CartController`: las pantallas leen `products` / `isLoading` /
/// `errorMessage` y nunca hablan con la API directamente.
///
/// Mantiene dos listas:
/// - [products]: lo que ve el cliente (activos con stock, `GET /products`).
/// - [adminProducts]: TODOS los productos (`GET /products/all`), solo se
///   carga si hay una sesion de administrador ([isAdmin]).
///
/// Si una recarga falla, se CONSERVAN los productos que ya estaban
/// cargados y se expone `errorMessage` para que la UI avise que pueden
/// estar desactualizados.
class ProductCatalog extends ChangeNotifier {
  ProductCatalog(this._repository, {bool Function()? isAdmin}) : _isAdmin = isAdmin;

  final ProductRepository _repository;
  final bool Function()? _isAdmin;

  List<Product> _products = [];
  List<Product> _adminProducts = [];
  bool isLoading = false;
  String? errorMessage;

  /// Productos del catalogo publico (activos con stock).
  List<Product> get products => List.unmodifiable(_products);

  /// Todos los productos (activos e inactivos). Vacio si no hay sesion admin.
  List<Product> get adminProducts => List.unmodifiable(_adminProducts);

  /// Productos activos para gestionar stock y alertas: incluye los que
  /// tienen stock 0 (el listado publico los oculta). Sin sesion admin cae
  /// al listado publico.
  List<Product> get stockProducts => _adminProducts.isEmpty
      ? products
      : List.unmodifiable(_adminProducts.where((p) => p.isActive));

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
          if (_isAdmin?.call() ?? false) {
            _adminProducts = await _repository.getAllProducts();
          } else {
            _adminProducts = [];
          }
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

  /// Edita nombre y precio (`PUT /products/:code`).
  Future<void> updateProduct(Product product) async {
    await _repository.updateProduct(product);
    await load();
  }

  /// Oculta el producto (borrado logico).
  Future<void> hideProduct(Product product) async {
    await _repository.hideProduct(product);
    await load();
  }

  Future<void> restoreProduct(Product product) async {
    await _repository.restoreProduct(product);
    await load();
  }

  /// Suma [quantity] unidades al stock.
  Future<void> addStock(Product product, int quantity) async {
    await _repository.addStock(product, quantity);
    await load();
  }

  /// Revision fisica de stock. Devuelve el detalle por producto.
  Future<List<StockReviewResult>> reviewStock(List<StockCount> counts) async {
    final results = await _repository.reviewStock(counts);
    await load();
    return results;
  }
}
