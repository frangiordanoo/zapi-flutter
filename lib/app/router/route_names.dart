/// Nombres de rutas centralizados.
///
/// Regla del proyecto: nadie navega con un String suelto
/// (`Navigator.pushNamed(context, '/algo')`). Siempre se usa una
/// constante de aca, por ejemplo:
///
/// ```dart
/// Navigator.pushNamed(context, RouteNames.clientScanner);
/// ```
///
/// Si agregas una pantalla nueva, agregala aca Y en
/// lib/app/router/app_router.dart (que es el unico lugar que sabe que
/// widget corresponde a cada nombre).
class RouteNames {
  RouteNames._();

  /// Splash / animacion de entrada de Zapi. Es la ruta inicial de la app.
  static const String splash = '/';

  // ---- Cliente ----------------------------------------------------
  /// Pantalla principal del cliente: el carrito.
  static const String clientCart = '/client/cart';
  static const String clientScanner = '/client/scanner';
  static const String clientProductList = '/client/product-list';
  static const String clientOnboarding = '/client/onboarding';
  static const String clientHelp = '/client/help';
  static const String clientSettings = '/client/settings';
  static const String clientCategories = '/client/categories';

  /// Recibe un [Product] como `arguments`.
  static const String clientProductDetail = '/client/product-detail';

  static const String clientCheckout = '/client/checkout';
  static const String clientOrderConfirmation = '/client/order-confirmation';

  // ---- Administrador ------------------------------------------------
  static const String adminLogin = '/admin/login';

  /// "Shell" del admin: contiene el bottom navigation con Estadisticas,
  /// Productos y Stock. Internamente decide que tab mostrar, por eso el
  /// resto de la app solo necesita conocer esta unica ruta.
  static const String adminHome = '/admin/home';

  static const String adminAddProduct = '/admin/add-product';
  static const String adminStockReview = '/admin/stock-review';
  static const String adminSalesHistory = '/admin/sales-history';
  static const String adminNotifications = '/admin/notifications';
  static const String adminProfile = '/admin/profile';

  /// Recibe un [Product] como `arguments`.
  static const String adminProductDetail = '/admin/product-detail';
}
