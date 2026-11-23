import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/core/network/api_client.dart';
import 'package:zapi/data/models/product.dart';
import 'package:zapi/data/models/stock_review.dart';
import 'package:zapi/data/services/product_service.dart';

/// [ProductService] que habla con la API real de Zapi.
class HttpProductService implements ProductService {
  HttpProductService(this._api);

  final ApiClient _api;

  @override
  Future<List<Product>> getProducts() => _fetchList('/products');

  @override
  Future<List<Product>> getAllProducts() => _fetchList('/products/all');

  Future<List<Product>> _fetchList(String path) async {
    final json = await _api.getJson(path);
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
    // (el catalogo se recarga despues desde la API).
    final created = _tryProduct(json);
    return created ?? product;
  }

  @override
  Future<Product> updateProduct(
    String code, {
    required String name,
    required double price,
  }) async {
    final json = await _api.putJson(
      '/products/${Uri.encodeComponent(code)}',
      {'name': name, 'price': price},
    );
    return _productFrom(json);
  }

  @override
  Future<Product> hideProduct(String code) async {
    final json = await _api.patchJson('/products/${Uri.encodeComponent(code)}');
    return _productFrom(json);
  }

  @override
  Future<Product> restoreProduct(String code) async {
    final json = await _api.patchJson('/products/${Uri.encodeComponent(code)}/restore');
    return _productFrom(json);
  }

  @override
  Future<Product> addStock(String code, int quantity) async {
    final json = await _api.patchJson(
      '/products/${Uri.encodeComponent(code)}/stock',
      {'quantity': quantity},
    );
    return _productFrom(json);
  }

  @override
  Future<List<StockReviewResult>> reviewStock(List<StockCount> counts) async {
    final json = await _api.postJson('/products/review-stock', {
      'products': [for (final count in counts) count.toJson()],
    });
    final results = json is Map<String, dynamic> ? json['results'] : null;
    if (results is! List) {
      throw const DataFormatException('La revisión de stock tiene un formato inesperado.');
    }
    return [
      for (final item in results)
        if (item is Map<String, dynamic>) StockReviewResult.fromJson(item),
    ];
  }

  /// Las respuestas de escritura son `{"message": "...", "product": {...}}`.
  Product _productFrom(dynamic json) {
    final product = _tryProduct(json);
    if (product == null) {
      throw const DataFormatException('La respuesta del producto tiene un formato inesperado.');
    }
    return product;
  }

  Product? _tryProduct(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final candidate = json['product'] is Map<String, dynamic>
        ? json['product'] as Map<String, dynamic>
        : json;
    try {
      return Product.fromJson(candidate);
    } on DataFormatException {
      return null;
    }
  }
}
