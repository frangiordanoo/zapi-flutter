import 'package:flutter_test/flutter_test.dart';
import 'package:zapi/data/models/stock_review.dart';
import 'package:zapi/data/repositories/product_repository.dart';

import '../support/fakes.dart';

void main() {
  late FakeProductService service;
  late ProductRepository repository;

  setUp(() {
    service = FakeProductService([
      testProduct(id: 1, code: 'A', name: 'Alfa', price: 100, stock: 10),
      testProduct(id: 2, code: 'B', name: 'Beta', price: 200, stock: 5),
      testProduct(id: 3, code: 'C', name: 'Gamma', price: 300, stock: 0),
    ]);
    repository = ProductRepository(service);
  });

  test('getProducts devuelve el listado publico (activos con stock)', () async {
    final products = await repository.getProducts();
    expect(products.map((p) => p.code), ['A', 'B']);
  });

  test('getAllProducts incluye productos sin stock', () async {
    final products = await repository.getAllProducts();
    expect(products.map((p) => p.code), ['A', 'B', 'C']);
  });

  test('findByCode devuelve el producto o null si no existe', () async {
    expect((await repository.findByCode('A'))?.name, 'Alfa');
    expect(await repository.findByCode('ZZZ'), isNull);
    expect(await repository.findByCode('   '), isNull);
  });

  test('createProduct delega en el servicio', () async {
    await repository.createProduct(testProduct(id: 0, code: 'D', name: 'Delta'));
    expect(service.products.where((p) => p.code == 'D'), hasLength(1));
  });

  test('updateProduct modifica nombre y precio en el servicio', () async {
    final alfa = (await repository.findByCode('A'))!;
    await repository.updateProduct(alfa.copyWith(name: 'Alfa editado', price: 150));

    final saved = service.products.firstWhere((p) => p.code == 'A');
    expect(saved.name, 'Alfa editado');
    expect(saved.price, 150);
    expect(saved.stock, 10, reason: 'editar no toca el stock');
  });

  test('hideProduct oculta y restoreProduct recupera', () async {
    final alfa = (await repository.findByCode('A'))!;

    await repository.hideProduct(alfa);
    expect(await repository.findByCode('A'), isNull);
    expect((await repository.getAllProducts()).firstWhere((p) => p.code == 'A').isActive,
        isFalse);

    await repository.restoreProduct(alfa);
    expect(await repository.findByCode('A'), isNotNull);
  });

  test('addStock SUMA unidades al stock', () async {
    final beta = (await repository.findByCode('B'))!;
    await repository.addStock(beta, 7);
    expect((await repository.findByCode('B'))?.stock, 12);
  });

  test('reviewStock deja el stock igual al conteo y informa diferencias', () async {
    final results = await repository.reviewStock(const [
      StockCount(code: 'A', physicalStock: 8),
      StockCount(code: 'B', physicalStock: 5),
    ]);

    expect(results.map((r) => r.status),
        [StockReviewStatus.missing, StockReviewStatus.correct]);
    expect(results.first.difference, 2);
    expect((await repository.findByCode('A'))?.stock, 8);
  });
}
