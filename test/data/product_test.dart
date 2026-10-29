import 'package:flutter_test/flutter_test.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/data/models/product.dart';

void main() {
  group('Product.fromJson', () {
    test('parsea la respuesta real de la API (precio como string)', () {
      final product = Product.fromJson({
        'id': 180002,
        'code': '7909883138066',
        'name': 'Agua mineral',
        'price': '1500',
        'stock': 17,
        'createdAt': '2026-07-03T12:45:21.818Z',
        'category': 'Bebidas',
      });

      expect(product.id, 180002);
      expect(product.code, '7909883138066');
      expect(product.price, 1500.0);
      expect(product.stock, 17);
      expect(product.category, 'Bebidas');
      expect(product.createdAt, DateTime.utc(2026, 7, 3, 12, 45, 21, 818));
    });

    test('el codigo siempre es String y conserva ceros iniciales', () {
      final fromString =
          Product.fromJson({'id': 1, 'code': '000123', 'name': 'A', 'price': 1});
      final fromNumber = Product.fromJson({'id': 2, 'code': 123, 'name': 'B', 'price': 1});

      expect(fromString.code, '000123');
      expect(fromNumber.code, '123');
    });

    test('acepta precios decimales como string o numero', () {
      expect(
          Product.fromJson({'id': 1, 'code': 'a', 'name': 'A', 'price': '49.99'}).price,
          49.99);
      expect(Product.fromJson({'id': 1, 'code': 'a', 'name': 'A', 'price': 45.5}).price,
          45.5);
    });

    test('categoria, stock y fecha nulos usan valores por defecto', () {
      final product = Product.fromJson({
        'id': 1,
        'code': 'a',
        'name': 'A',
        'price': 10,
        'category': null,
        'stock': null,
        'createdAt': null,
      });

      expect(product.category, Product.defaultCategory);
      expect(product.stock, 0);
      expect(product.createdAt, isNull);
    });

    test('lanza DataFormatException si faltan campos obligatorios', () {
      expect(() => Product.fromJson({'id': 1, 'name': 'A', 'price': 1}),
          throwsA(isA<DataFormatException>()));
      expect(() => Product.fromJson({'id': 1, 'code': 'a', 'price': 1}),
          throwsA(isA<DataFormatException>()));
      expect(() => Product.fromJson({'id': 1, 'code': 'a', 'name': 'A'}),
          throwsA(isA<DataFormatException>()));
      expect(() => Product.fromJson({'code': 'a', 'name': 'A', 'price': 1}),
          throwsA(isA<DataFormatException>()));
    });
  });

  test('toJson solo incluye los campos que espera el backend', () {
    const product = Product(
      id: 0,
      code: 'PROD-001',
      name: 'Teclado Mecánico RGB',
      price: 45.99,
      stock: 15,
      category: 'Periféricos',
    );

    expect(product.toJson(), {
      'code': 'PROD-001',
      'name': 'Teclado Mecánico RGB',
      'price': 45.99,
      'stock': 15,
      'category': 'Periféricos',
    });
  });
}
