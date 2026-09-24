import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/router/app_router.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_theme.dart';
import 'package:zapi/core/constants/app_constants.dart';
import 'package:zapi/services/mock_product_service.dart';
import 'package:zapi/state/cart_controller.dart';
import 'package:zapi/state/product_catalog.dart';

/// Widget raiz de la app.
///
/// Aca se arma el arbol de estado global (Provider) y se configura el
/// `MaterialApp` (tema + routing). Si el dia de mañana `MockProductService`
/// se reemplaza por un `ApiProductService` real, el UNICO cambio
/// necesario es la linea `ProductCatalog(MockProductService())` de aca
/// abajo.
class ZapiApp extends StatelessWidget {
  const ZapiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(
          create: (_) => ProductCatalog(MockProductService())..load(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: RouteNames.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
