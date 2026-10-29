import 'package:flutter_test/flutter_test.dart';
import 'package:zapi/data/repositories/product_repository.dart';

import '../support/fakes.dart';

void main() {
  late FakeProductService service;
  late ProductRepository repository;

  setUp(() {
    service = FakeProductService([
      testProduct(id: 1, code: 'A', name: 'Alfa', price: 100, stock: 10),
      testProduct(id: 2, code: 'B', name: 'Beta', price: 200, stock: 5),
    ]);
    repository = ProductRepository(service);
  });

  test('getProducts devuelve lo que entrega el servicio', () async {
    final products = await repository.getProducts();
    expect(products.map((p) => p.code), ['A', 'B']);
  });

  test('findByCode devuelve el producto o null si no existe', () async {
    expect((await repository.findByCode('A'))?.name, 'Alfa');
    expect(await repository.findByCode('ZZZ'), isNull);
    expect(await repository.findByCode('   '), isNull);
  });

  test('createProduct delega en el servicio y no duplica al recargar', () async {
    await repository.createProduct(testProduct(id: 0, code: 'C', name: 'Gamma'));
    final products = await repository.getProducts();
    expect(products.where((p) => p.code == 'C'), hasLength(1));
  });

  test('editar superpone los cambios locales sin perder el id de la API', () async {
    final alfa = (await repository.getProducts()).first;
    await repository.updateProduct(alfa.copyWith(name: 'Alfa editado', price: 150));

    final reloaded = (await repository.getProducts()).firstWhere((p) => p.code == 'A');
    expect(reloaded.name, 'Alfa editado');
    expect(reloaded.price, 150);
    expect(reloaded.id, 1);
    expect(service.products.first.name, 'Alfa', reason: 'la API no se modifica');
  });

  test('borrar oculta el producto en listado y busqueda', () async {
    final alfa = (await repository.getProducts()).first;
    await repository.deleteProduct(alfa);

    expect((await repository.getProducts()).map((p) => p.code), ['B']);
    expect(await repository.findByCode('A'), isNull);
  });

  test('corregir stock se conserva al recargar', () async {
    final beta = (await repository.getProducts()).last;
    await repository.updateStock(beta, 42);

    expect((await repository.findByCode('B'))?.stock, 42);
    expect((await repository.getProducts()).last.stock, 42);
  });
}
