import 'package:zapi/models/product.dart';

/// Contrato para todo lo que la app necesita hacer con productos.
///
/// Hoy la unica implementacion es [MockProductService] (datos locales).
/// El dia que exista backend, se crea una `ApiProductService implements
/// ProductService` que haga los llamados HTTP reales, y se cambia UNA
/// linea en `lib/app/app.dart` (donde se crea el Provider). Las pantallas
/// no deberian tener que cambiar nada porque siempre hablan contra esta
/// interfaz, nunca contra la implementacion concreta.
abstract class ProductService {
  /// Devuelve todos los productos que no fueron borrados (isDeleted == false).
  Future<List<Product>> getProducts();

  /// Busca un producto por su codigo de barras. `null` si no existe.
  ///
  /// TODO(backend): en el futuro esto va a hacer un GET /products/code/:code
  Future<Product?> getProductByCode(String code);

  /// Crea un producto nuevo.
  ///
  /// TODO(backend): en el futuro esto va a hacer un POST /products
  Future<Product> createProduct(Product product);

  /// Actualiza un producto existente (nombre y precio, ver Admin > Productos).
  ///
  /// TODO(backend): en el futuro esto va a hacer un PUT/PATCH /products/:id
  Future<Product> updateProduct(Product product);

  /// Marca un producto como borrado (soft delete). No lo elimina de verdad.
  ///
  /// TODO(backend): en el futuro esto va a hacer un DELETE /products/:id
  /// que en el servidor setee `isDeleted = true` en vez de borrar la fila.
  Future<void> deleteProduct(int id);

  /// Actualiza el stock de un producto luego de un recuento fisico
  /// (ver Admin > Stock Review).
  ///
  /// TODO(backend): en el futuro esto va a hacer un PATCH /products/:id/stock
  Future<Product> updateStock(int id, int newStock);
}
