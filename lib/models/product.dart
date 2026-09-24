/// Modelo de producto.
///
/// Refleja el modelo actual del backend (Prisma):
///
/// ```prisma
/// model Product {
///   id        Int        @id @default(autoincrement())
///   code      String     @unique
///   name      String
///   price     Decimal    @db.Decimal(10, 2)
///   stock     Int
///   createdAt DateTime   @default(now())
///   category  String
///
///   saleItems SaleItem[]
/// }
/// ```
///
/// IMPORTANTE - `isDeleted`:
/// Este campo NO existe todavia en el backend. Se agrega aca para dejar
/// preparado el "soft delete" de productos (ver pantalla Admin > Productos).
/// Cuando el backend lo incorpore, el campo Prisma equivalente deberia ser:
///
/// ```prisma
/// isDeleted Boolean @default(false)
/// ```
///
/// Hasta que eso exista, el borrado de productos solo se simula
/// localmente marcando `isDeleted = true` (ver MockProductService).
class Product {
  final int id;
  final String code;
  final String name;
  final double price;
  final int stock;
  final DateTime createdAt;
  final String category;
  final bool isDeleted;

  const Product({
    required this.id,
    required this.code,
    required this.name,
    required this.price,
    required this.stock,
    required this.createdAt,
    required this.category,
    this.isDeleted = false,
  });

  Product copyWith({
    int? id,
    String? code,
    String? name,
    double? price,
    int? stock,
    DateTime? createdAt,
    String? category,
    bool? isDeleted,
  }) {
    return Product(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
