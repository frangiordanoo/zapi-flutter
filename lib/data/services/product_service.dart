import 'package:zapi/data/models/product.dart';

/// Contrato de acceso a la fuente de datos de productos. Solo expone lo
/// que el backend soporta hoy: listar, buscar por codigo y crear.
///
/// La implementacion real es `HttpProductService`; en los tests se usa
/// una falsa. Nadie fuera de `ProductRepository` deberia usar esta
/// interfaz directamente.
abstract class ProductService {
  /// `GET /products`
  Future<List<Product>> getProducts();

  /// `GET /products/:code`. Devuelve `null` si el producto no existe.
  Future<Product?> getProductByCode(String code);

  /// `POST /products` con el body `{"product": {...}}`.
  Future<Product> createProduct(Product product);
}
