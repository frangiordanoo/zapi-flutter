import 'package:zapi/models/product.dart';

/// Catalogo de productos "de mentira" usado por [MockProductService].
///
/// Centralizado aca a proposito: si necesitas agregar/cambiar un
/// producto de prueba, este es el unico lugar que hay que tocar.
///
/// Los codigos de barra siguen el formato real de EAN-13 argentino
/// (empiezan con 779) pero son inventados.
final List<Product> mockProducts = [
  Product(
    id: 1,
    code: '7791234567890',
    name: 'Coca Cola 500ml',
    price: 1700,
    stock: 24,
    createdAt: DateTime(2026, 1, 10),
    category: 'Bebidas',
  ),
  Product(
    id: 2,
    code: '7799876543210',
    name: 'Pepsi 500ml',
    price: 1700,
    stock: 18,
    createdAt: DateTime(2026, 1, 10),
    category: 'Bebidas',
  ),
  Product(
    id: 3,
    code: '7790001112223',
    name: 'Agua Mineral 500ml',
    price: 1200,
    stock: 30,
    createdAt: DateTime(2026, 1, 11),
    category: 'Bebidas',
  ),
  Product(
    id: 4,
    code: '7794445556667',
    name: 'Alfajor Milka',
    price: 2500,
    stock: 15,
    createdAt: DateTime(2026, 1, 12),
    category: 'Golosinas',
  ),
  Product(
    id: 5,
    code: '7797778889990',
    name: 'Papas Lay\'s Clasicas',
    price: 2200,
    stock: 12,
    createdAt: DateTime(2026, 1, 12),
    category: 'Snacks',
  ),
  Product(
    id: 6,
    code: '7791112223334',
    name: 'Chocolate Milka',
    price: 2500,
    stock: 20,
    createdAt: DateTime(2026, 1, 13),
    category: 'Golosinas',
  ),
  Product(
    id: 7,
    code: '7793334445556',
    name: 'Galletitas Oreo',
    price: 1800,
    stock: 3,
    createdAt: DateTime(2026, 1, 13),
    category: 'Golosinas',
  ),
  Product(
    id: 8,
    code: '7795556667778',
    name: 'Jugo Cepita 200ml',
    price: 900,
    stock: 25,
    createdAt: DateTime(2026, 1, 14),
    category: 'Bebidas',
  ),
  Product(
    id: 9,
    code: '7796667778889',
    name: 'Yerba Mate CBSe 1kg',
    price: 3200,
    stock: 8,
    createdAt: DateTime(2026, 1, 14),
    category: 'Almacen',
  ),
  Product(
    id: 10,
    code: '7798889990001',
    name: 'Cafe Instantaneo La Virginia',
    price: 3200,
    stock: 0,
    createdAt: DateTime(2026, 1, 15),
    category: 'Almacen',
  ),
];
