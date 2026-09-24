import 'package:flutter/material.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/features/admin/add_product/admin_add_product_screen.dart';
import 'package:zapi/features/admin/admin_shell.dart';
import 'package:zapi/features/admin/login/admin_login_screen.dart';
import 'package:zapi/features/admin/stock_review/admin_stock_review_screen.dart';
import 'package:zapi/features/client/cart/client_cart_screen.dart';
import 'package:zapi/features/client/product_list/client_product_list_screen.dart';
import 'package:zapi/features/client/scanner/client_scanner_screen.dart';
import 'package:zapi/features/splash/splash_screen.dart';

/// Routing centralizado de la app.
///
/// Como navegar entre pantallas (siempre con las constantes de
/// [RouteNames], nunca con Strings sueltos):
///
/// ```dart
/// // Ir a una pantalla nueva (se puede volver con el boton atras / pop):
/// Navigator.pushNamed(context, RouteNames.clientScanner);
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
        return _page(const ClientProductListScreen(), settings);

      // ---- Administrador ---------------------------------------------
      case RouteNames.adminLogin:
        return _page(const AdminLoginScreen(), settings);

      case RouteNames.adminHome:
        return _page(const AdminShell(), settings);

      case RouteNames.adminAddProduct:
        return _page(const AdminAddProductScreen(), settings);

      case RouteNames.adminStockReview:
        return _page(const AdminStockReviewScreen(), settings);

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
