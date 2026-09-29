import 'package:flutter/material.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/features/admin/add_product/admin_add_product_screen.dart';
import 'package:zapi/features/admin/admin_shell.dart';
import 'package:zapi/features/admin/login/admin_login_screen.dart';
import 'package:zapi/features/admin/notifications/admin_notifications_screen.dart';
import 'package:zapi/features/admin/product_detail/admin_product_detail_screen.dart';
import 'package:zapi/features/admin/profile/admin_profile_screen.dart';
import 'package:zapi/features/admin/sales_history/admin_sales_history_screen.dart';
import 'package:zapi/features/admin/stock_review/admin_stock_review_screen.dart';
import 'package:zapi/features/client/cart/client_cart_screen.dart';
import 'package:zapi/features/client/categories/client_categories_screen.dart';
import 'package:zapi/features/client/checkout/client_checkout_screen.dart';
import 'package:zapi/features/client/checkout/client_order_confirmation_screen.dart';
import 'package:zapi/features/client/help/client_help_screen.dart';
import 'package:zapi/features/client/onboarding/client_onboarding_screen.dart';
import 'package:zapi/features/client/product_detail/client_product_detail_screen.dart';
import 'package:zapi/features/client/product_list/client_product_list_screen.dart';
import 'package:zapi/features/client/scanner/client_scanner_screen.dart';
import 'package:zapi/features/client/settings/client_settings_screen.dart';
import 'package:zapi/features/splash/splash_screen.dart';
import 'package:zapi/models/product.dart';

/// Routing centralizado de la app.
///
/// Como navegar entre pantallas (siempre con las constantes de
/// [RouteNames], nunca con Strings sueltos):
///
/// ```dart
/// // Ir a una pantalla nueva (se puede volver con el boton atras / pop):
/// Navigator.pushNamed(context, RouteNames.clientScanner);
///
/// // Con argumentos (ej: detalle de producto):
/// Navigator.pushNamed(context, RouteNames.clientProductDetail, arguments: product);
///
/// // Reemplazar la pantalla actual (no se puede volver, ej: despues del login):
/// Navigator.pushReplacementNamed(context, RouteNames.adminHome);
///
/// // Volver a la pantalla anterior:
/// Navigator.pop(context);
/// ```
///
/// `AppRouter.generateRoute` se conecta en `MaterialApp.onGenerateRoute`
/// (ver lib/app/app.dart). Si agregas una pantalla nueva:
///   1. Agregale un nombre en route_names.dart
///   2. Agregale un `case` aca abajo
class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return _page(const SplashScreen(), settings);

      // ---- Cliente --------------------------------------------------
      case RouteNames.clientCart:
        return _page(const ClientCartScreen(), settings);

      case RouteNames.clientScanner:
        return _page(const ClientScannerScreen(), settings);

      case RouteNames.clientProductList:
        return _page(
          ClientProductListScreen(categoryFilter: settings.arguments as String?),
          settings,
        );

      case RouteNames.clientProductDetail:
        return _page(
          ClientProductDetailScreen(product: settings.arguments as Product),
          settings,
        );

      case RouteNames.clientOnboarding:
        return _page(const ClientOnboardingScreen(), settings);

      case RouteNames.clientHelp:
        return _page(const ClientHelpScreen(), settings);

      case RouteNames.clientSettings:
        return _page(const ClientSettingsScreen(), settings);

      case RouteNames.clientCategories:
        return _page(const ClientCategoriesScreen(), settings);

      case RouteNames.clientCheckout:
        return _page(const ClientCheckoutScreen(), settings);

      case RouteNames.clientOrderConfirmation:
        return _page(const ClientOrderConfirmationScreen(), settings);

      // ---- Administrador ---------------------------------------------
      case RouteNames.adminLogin:
        return _page(const AdminLoginScreen(), settings);

      case RouteNames.adminHome:
        return _page(const AdminShell(), settings);

      case RouteNames.adminAddProduct:
        return _page(const AdminAddProductScreen(), settings);

      case RouteNames.adminStockReview:
        return _page(const AdminStockReviewScreen(), settings);

      case RouteNames.adminProductDetail:
        return _page(
          AdminProductDetailScreen(product: settings.arguments as Product),
          settings,
        );

      case RouteNames.adminSalesHistory:
        return _page(const AdminSalesHistoryScreen(), settings);

      case RouteNames.adminNotifications:
        return _page(const AdminNotificationsScreen(), settings);

      case RouteNames.adminProfile:
        return _page(const AdminProfileScreen(), settings);

      default:
        return _page(
          Scaffold(
            body: Center(
              child: Text('Ruta no encontrada: ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  static MaterialPageRoute<dynamic> _page(
    Widget child,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(builder: (_) => child, settings: settings);
  }
}
