import 'package:zapi/data/models/product.dart';
import 'package:zapi/data/services/product_service.dart';

/// Producto de prueba con la misma forma que los de la API de Zapi.
Product testProduct({
  int id = 1,
  String code = '7790000000001',
  String name = 'Producto de prueba',
  double price = 1000,
  int stock = 10,
  String category = 'Categoria de prueba',
}) {
  return Product(
    id: id,
    code: code,
    name: name,
    price: price,
    stock: stock,
    category: category,
  );
}

/// [ProductService] en memoria para tests (nunca toca la red).
class FakeProductService implements ProductService {
  FakeProductService(List<Product> products) : products = List.of(products);

  final List<Product> products;
  Object? errorToThrow;
  int getProductsCalls = 0;

  @override
  Future<List<Product>> getProducts() async {
    getProductsCalls++;
    if (errorToThrow != null) throw errorToThrow!;
    return List.of(products);
  }

  @override
  Future<Product?> getProductByCode(String code) async {
    if (errorToThrow != null) throw errorToThrow!;
    for (final p in products) {
      if (p.code == code) return p;
    }
    return null;
  }

  @override
  Future<Product> createProduct(Product product) async {
    if (errorToThrow != null) throw errorToThrow!;
    final created = product.copyWith(id: products.length + 100);
    products.add(created);
    return created;
  }
}
