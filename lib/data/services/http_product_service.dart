import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/core/network/api_client.dart';
import 'package:zapi/data/models/product.dart';
import 'package:zapi/data/services/product_service.dart';

/// [ProductService] que habla con la API real de Zapi.
class HttpProductService implements ProductService {
  HttpProductService(this._api);

  final ApiClient _api;

  @override
  Future<List<Product>> getProducts() async {
    final json = await _api.getJson('/products');
    if (json is! List) {
      throw const DataFormatException('La lista de productos tiene un formato inesperado.');
    }

    final products = <Product>[];
    for (final item in json) {
      if (item is! Map<String, dynamic>) continue;
      try {
        products.add(Product.fromJson(item));
      } on DataFormatException {
        // Un producto roto no deberia tirar abajo todo el listado.
      }
    }

    if (json.isNotEmpty && products.isEmpty) {
      throw const DataFormatException('Ningún producto de la API tiene el formato esperado.');
    }
    return products;
  }

  @override
  Future<Product?> getProductByCode(String code) async {
    try {
      // El codigo es texto: se codifica para que cualquier caracter
      // especial no rompa la URL.
      final json = await _api.getJson('/products/${Uri.encodeComponent(code)}');
      if (json is! Map<String, dynamic>) {
        throw const DataFormatException('El producto tiene un formato inesperado.');
      }
      return Product.fromJson(json);
    } on ApiException catch (e) {
      if (e.isNotFound) return null;
      rethrow;
    }
  }

  @override
  Future<Product> createProduct(Product product) async {
    final json = await _api.postJson('/products', {'product': product.toJson()});

    // Se intenta leer el producto creado de la respuesta; si el backend
    // devuelve otra cosa, igual alcanza con que el POST haya sido exitoso
    // (el catalogo se recarga despues desde GET /products).
    final candidate = json is Map<String, dynamic>
        ? (json['product'] is Map<String, dynamic>
            ? json['product'] as Map<String, dynamic>
            : json)
        : null;
    if (candidate != null) {
      try {
        return Product.fromJson(candidate);
      } on DataFormatException {
        // Se usa el producto enviado.
      }
    }
    return product;
  }
}
