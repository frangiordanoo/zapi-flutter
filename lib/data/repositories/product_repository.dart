import 'package:zapi/data/models/product.dart';
import 'package:zapi/data/models/stock_review.dart';
import 'package:zapi/data/services/product_service.dart';

/// Intermediario entre las pantallas/estado y la API de productos.
///
/// Todas las operaciones (incluidas editar, ocultar, recuperar, sumar stock
/// y revisar stock) se mandan al backend: ya no hay cambios "solo en
/// memoria". Las operaciones de administrador necesitan una sesion con
/// token (ver `AuthController`); si no, la API responde 401/403.
class ProductRepository {
  ProductRepository(this._service);

  final ProductService _service;

  /// Productos activos con stock (lo que ve el cliente).
  Future<List<Product>> getProducts() => _service.getProducts();

  /// ADMIN. Todos los productos, activos e inactivos.
  Future<List<Product>> getAllProducts() => _service.getAllProducts();

  /// `null` si el producto no existe.
  Future<Product?> findByCode(String code) {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return Future.value(null);
    return _service.getProductByCode(trimmed);
  }

  Future<Product> createProduct(Product product) => _service.createProduct(product);

  /// Edita SOLO nombre y precio (lo unico que permite el backend).
  Future<Product> updateProduct(Product product) =>
      _service.updateProduct(product.code, name: product.name, price: product.price);

  /// Borrado logico: el producto queda inactivo y se puede recuperar.
  Future<Product> hideProduct(Product product) => _service.hideProduct(product.code);

  Future<Product> restoreProduct(Product product) => _service.restoreProduct(product.code);

  /// Suma [quantity] unidades al stock actual (no lo reemplaza).
  Future<Product> addStock(Product product, int quantity) =>
      _service.addStock(product.code, quantity);

  /// Revision fisica: el backend deja el stock igual al conteo.
  Future<List<StockReviewResult>> reviewStock(List<StockCount> counts) =>
      _service.reviewStock(counts);
}
