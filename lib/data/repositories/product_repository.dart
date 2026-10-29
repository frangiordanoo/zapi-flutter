import 'package:zapi/data/models/product.dart';
import 'package:zapi/data/services/product_service.dart';

/// Intermediario entre las pantallas/estado y la API de productos.
///
/// Lo que el backend SI soporta (listar, buscar por codigo, crear) se
/// delega en [ProductService]. Editar, borrar y corregir stock todavia NO
/// tienen endpoint, asi que esos cambios se guardan SOLO en memoria
/// (mientras la app esta abierta) y se superponen a lo que devuelve la API:
/// no se pierden al refrescar el listado, pero tampoco llegan al servidor.
/// Cuando el backend sume esos endpoints, solo hay que reemplazar los tres
/// metodos marcados con TODO(backend).
class ProductRepository {
  ProductRepository(this._service);

  final ProductService _service;

  final Map<String, Product> _localEdits = {};
  final Set<String> _locallyDeletedCodes = {};

  Future<List<Product>> getProducts() async {
    final remote = await _service.getProducts();
    return [
      for (final product in remote)
        if (!_locallyDeletedCodes.contains(product.code)) _withLocalEdits(product),
    ];
  }

  /// `null` si el producto no existe (o fue borrado localmente).
  Future<Product?> findByCode(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty || _locallyDeletedCodes.contains(trimmed)) return null;
    final product = await _service.getProductByCode(trimmed);
    return product == null ? null : _withLocalEdits(product);
  }

  Future<Product> createProduct(Product product) async {
    final created = await _service.createProduct(product);
    _locallyDeletedCodes.remove(created.code);
    _localEdits.remove(created.code);
    return created;
  }

  // TODO(backend): PUT/PATCH /products/:id
  Future<void> updateProduct(Product product) async {
    _localEdits[product.code] = product;
  }

  // TODO(backend): DELETE /products/:id (borrado logico)
  Future<void> deleteProduct(Product product) async {
    _locallyDeletedCodes.add(product.code);
    _localEdits.remove(product.code);
  }

  // TODO(backend): PATCH /products/:id/stock
  Future<void> updateStock(Product product, int newStock) async {
    final base = _localEdits[product.code] ?? product;
    _localEdits[product.code] = base.copyWith(stock: newStock);
  }

  Product _withLocalEdits(Product remote) {
    final edit = _localEdits[remote.code];
    if (edit == null) return remote;
    return edit.copyWith(id: remote.id, createdAt: remote.createdAt);
  }
}
