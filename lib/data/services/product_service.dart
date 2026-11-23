import 'package:zapi/data/models/product.dart';
import 'package:zapi/data/models/stock_review.dart';

/// Contrato de acceso a la fuente de datos de productos (API de Zapi).
///
/// La implementacion real es `HttpProductService`; en los tests se usa
/// una falsa. Nadie fuera de `ProductRepository` deberia usar esta
/// interfaz directamente.
///
/// Los metodos marcados "ADMIN" requieren una sesion de administrador
/// (token Bearer); sin ella el backend responde 401/403 y se lanza una
/// `ApiException`.
abstract class ProductService {
  /// `GET /products` (publico): productos activos con stock disponible.
  Future<List<Product>> getProducts();

  /// `GET /products/:code` (publico). Devuelve `null` si no existe.
  Future<Product?> getProductByCode(String code);

  /// ADMIN. `GET /products/all`: activos e inactivos, con o sin stock.
  Future<List<Product>> getAllProducts();

  /// ADMIN. `POST /products` con el body `{"product": {...}}`.
  Future<Product> createProduct(Product product);

  /// ADMIN. `PUT /products/:code`: solo cambia nombre y precio.
  Future<Product> updateProduct(String code, {required String name, required double price});

  /// ADMIN. `PATCH /products/:code`: oculta el producto (borrado logico).
  Future<Product> hideProduct(String code);

  /// ADMIN. `PATCH /products/:code/restore`: vuelve a activar un producto.
  Future<Product> restoreProduct(String code);

  /// ADMIN. `PATCH /products/:code/stock`: SUMA [quantity] unidades.
  Future<Product> addStock(String code, int quantity);

  /// ADMIN. `POST /products/review-stock`: compara el conteo fisico con el
  /// registrado y deja el stock igual al fisico.
  Future<List<StockReviewResult>> reviewStock(List<StockCount> counts);
}
