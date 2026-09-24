import 'package:zapi/mock/mock_products.dart';
import 'package:zapi/models/product.dart';
import 'package:zapi/services/product_service.dart';

/// Implementacion "de mentira" de [ProductService] que trabaja sobre la
/// lista en memoria `mockProducts` (ver lib/mock/mock_products.dart).
///
/// Simula latencia de red con `Future.delayed` para que las pantallas ya
/// queden preparadas para el dia que esto sea una llamada HTTP real
/// (loading states, etc.).
class MockProductService implements ProductService {
  // Lista mutable en memoria. Funciona como una "base de datos" falsa
  // compartida durante la vida de la app (se resetea al reiniciarla).
  final List<Product> _products = List<Product>.from(mockProducts);

  static const _simulatedDelay = Duration(milliseconds: 300);

  @override
  Future<List<Product>> getProducts() async {
    await Future.delayed(_simulatedDelay);
    return _products.where((p) => !p.isDeleted).toList();
  }

  @override
  Future<Product?> getProductByCode(String code) async {
    await Future.delayed(_simulatedDelay);
    try {
      return _products.firstWhere((p) => p.code == code && !p.isDeleted);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Product> createProduct(Product product) async {
    await Future.delayed(_simulatedDelay);
    final nextId = _products.isEmpty
        ? 1
        : _products.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
    final created = product.copyWith(id: nextId, createdAt: DateTime.now());
    _products.add(created);
    return created;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    await Future.delayed(_simulatedDelay);
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index == -1) {
      throw StateError('Producto ${product.id} no encontrado');
    }
    _products[index] = product;
    return product;
  }

  @override
  Future<void> deleteProduct(int id) async {
    await Future.delayed(_simulatedDelay);
    final index = _products.indexWhere((p) => p.id == id);
    if (index == -1) return;
    // Soft delete: nunca se quita de la lista, solo se marca.
    _products[index] = _products[index].copyWith(isDeleted: true);
  }

  @override
  Future<Product> updateStock(int id, int newStock) async {
    await Future.delayed(_simulatedDelay);
    final index = _products.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw StateError('Producto $id no encontrado');
    }
    _products[index] = _products[index].copyWith(stock: newStock);
    return _products[index];
  }
}
