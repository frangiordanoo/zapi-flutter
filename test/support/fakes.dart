import 'package:zapi/data/models/cart_item.dart';
import 'package:zapi/data/models/product.dart';
import 'package:zapi/data/models/sale.dart';
import 'package:zapi/data/models/stock_review.dart';
import 'package:zapi/data/services/checkout_service.dart';
import 'package:zapi/data/services/product_service.dart';
import 'package:zapi/data/services/sales_data_source.dart';

/// Producto de prueba con la misma forma que los de la API de Zapi.
Product testProduct({
  int id = 1,
  String code = '7790000000001',
  String name = 'Producto de prueba',
  double price = 1000,
  int stock = 10,
  String category = 'Categoria de prueba',
  bool isActive = true,
}) {
  return Product(
    id: id,
    code: code,
    name: name,
    price: price,
    stock: stock,
    category: category,
    isActive: isActive,
  );
}

/// [ProductService] en memoria para tests (nunca toca la red). Imita las
/// reglas del backend: el listado publico solo trae activos con stock.
class FakeProductService implements ProductService {
  FakeProductService(List<Product> products) : products = List.of(products);

  final List<Product> products;
  Object? errorToThrow;
  int getProductsCalls = 0;
  int getAllProductsCalls = 0;

  @override
  Future<List<Product>> getProducts() async {
    getProductsCalls++;
    if (errorToThrow != null) throw errorToThrow!;
    return products.where((p) => p.isActive && p.stock > 0).toList();
  }

  @override
  Future<List<Product>> getAllProducts() async {
    getAllProductsCalls++;
    if (errorToThrow != null) throw errorToThrow!;
    return List.of(products);
  }

  @override
  Future<Product?> getProductByCode(String code) async {
    if (errorToThrow != null) throw errorToThrow!;
    for (final p in products) {
      if (p.code == code && p.isActive) return p;
    }
    return null;
  }

  @override
  Future<Product> createProduct(Product product) async {
    if (errorToThrow != null) throw errorToThrow!;
    final created = product.copyWith(id: products.length + 100);
    products.add(created);
    return created;
  }

  Product _replace(String code, Product Function(Product) change) {
    final index = products.indexWhere((p) => p.code == code);
    products[index] = change(products[index]);
    return products[index];
  }

  @override
  Future<Product> updateProduct(String code,
      {required String name, required double price}) async {
    if (errorToThrow != null) throw errorToThrow!;
    return _replace(code, (p) => p.copyWith(name: name, price: price));
  }

  @override
  Future<Product> hideProduct(String code) async {
    if (errorToThrow != null) throw errorToThrow!;
    return _replace(code, (p) => p.copyWith(isActive: false));
  }

  @override
  Future<Product> restoreProduct(String code) async {
    if (errorToThrow != null) throw errorToThrow!;
    return _replace(code, (p) => p.copyWith(isActive: true));
  }

  @override
  Future<Product> addStock(String code, int quantity) async {
    if (errorToThrow != null) throw errorToThrow!;
    return _replace(code, (p) => p.copyWith(stock: p.stock + quantity));
  }

  @override
  Future<List<StockReviewResult>> reviewStock(List<StockCount> counts) async {
    if (errorToThrow != null) throw errorToThrow!;
    final results = <StockReviewResult>[];
    for (final count in counts) {
      final product = _replace(count.code, (p) => p);
      final difference = (count.physicalStock - product.stock).abs();
      results.add(StockReviewResult(
        code: product.code,
        name: product.name,
        databaseStock: product.stock,
        physicalStock: count.physicalStock,
        difference: difference,
        status: count.physicalStock == product.stock
            ? StockReviewStatus.correct
            : count.physicalStock < product.stock
                ? StockReviewStatus.missing
                : StockReviewStatus.surplus,
      ));
      _replace(count.code, (p) => p.copyWith(stock: count.physicalStock));
    }
    return results;
  }
}

/// [SalesDataSource] falso: devuelve las ventas dadas (o lanza un error).
class FakeSalesSource implements SalesDataSource {
  FakeSalesSource(this.sales);

  List<Sale> sales;
  Object? errorToThrow;
  int fetchCalls = 0;

  @override
  Future<List<Sale>> fetchSales() async {
    fetchCalls++;
    if (errorToThrow != null) throw errorToThrow!;
    return List.of(sales);
  }
}

/// [CheckoutService] falso: guarda el carrito recibido y devuelve un link.
class FakeCheckoutService implements CheckoutService {
  Object? errorToThrow;
  List<CartItem>? lastItems;

  static final Uri link = Uri.parse('https://www.mercadopago.com.ar/checkout/v1/redirect?pref_id=123');

  @override
  Future<Uri> createCheckout(List<CartItem> items) async {
    if (errorToThrow != null) throw errorToThrow!;
    lastItems = items;
    return link;
  }
}
