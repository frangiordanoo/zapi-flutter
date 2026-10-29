import 'package:zapi/core/errors/app_exception.dart';

/// Producto del catalogo. Refleja la respuesta real de la API
/// (`GET https://zapi-rqos.onrender.com/products`):
///
/// ```json
/// {"id": 180002, "code": "7909883138066", "name": "Agua mineral",
///  "price": "1500", "stock": 17, "category": "Bebidas",
///  "createdAt": "2026-07-03T12:45:21.818Z"}
/// ```
///
/// Notas del parseo:
/// - `code` es SIEMPRE un `String` (puede tener ceros iniciales o letras).
/// - `price` llega como string (es un `Decimal` en el backend) pero se
///   acepta tambien un numero.
/// - `category` y `createdAt` pueden faltar: se usan valores por defecto
///   en vez de romper todo el listado.
class Product {
  final int id;
  final String code;
  final String name;
  final double price;
  final int stock;
  final DateTime? createdAt;
  final String category;

  static const String defaultCategory = 'Sin categoría';

  const Product({
    required this.id,
    required this.code,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final code = json['code']?.toString().trim() ?? '';
    final name = json['name']?.toString().trim() ?? '';
    final id = _asInt(json['id']);
    final price = _asDouble(json['price']);

    if (code.isEmpty || name.isEmpty || id == null || price == null) {
      throw const DataFormatException('Un producto de la API tiene datos incompletos.');
    }

    final category = json['category']?.toString().trim() ?? '';
    final createdAt = json['createdAt'] is String
        ? DateTime.tryParse(json['createdAt'] as String)
        : null;

    return Product(
      id: id,
      code: code,
      name: name,
      price: price,
      stock: _asInt(json['stock']) ?? 0,
      category: category.isEmpty ? defaultCategory : category,
      createdAt: createdAt,
    );
  }

  /// Campos que el backend espera dentro de `{"product": {...}}` al crear.
  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'price': price,
        'stock': stock,
        'category': category,
      };

  Product copyWith({
    int? id,
    String? code,
    String? name,
    double? price,
    int? stock,
    DateTime? createdAt,
    String? category,
  }) {
    return Product(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim().replaceAll(',', '.'));
    return null;
  }
}
