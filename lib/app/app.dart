import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/router/app_router.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_theme.dart';
import 'package:zapi/core/constants/app_constants.dart';
import 'package:zapi/core/network/api_client.dart';
import 'package:zapi/data/mocks/mock_sales_data_source.dart';
import 'package:zapi/data/repositories/product_repository.dart';
import 'package:zapi/data/repositories/stats_repository.dart';
import 'package:zapi/data/services/http_product_service.dart';
import 'package:zapi/features/admin/stats/stats_controller.dart';
import 'package:zapi/state/cart_controller.dart';
import 'package:zapi/state/product_catalog.dart';

/// Widget raiz de la app: arma las dependencias (API -> servicio ->
/// repositorio -> estado) y configura el `MaterialApp`.
///
/// Los repositorios se pueden inyectar desde afuera (los tests lo usan
/// para no tocar la red); en la app real se crean los de produccion.
class ZapiApp extends StatelessWidget {
  const ZapiApp({super.key, this.productRepository, this.statsRepository});

  final ProductRepository? productRepository;
  final StatsRepository? statsRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ProductRepository>(
          create: (_) =>
              productRepository ?? ProductRepository(HttpProductService(ApiClient())),
        ),
        Provider<StatsRepository>(
          create: (context) =>
              statsRepository ??
              StatsRepository(
                salesSource: MockSalesDataSource(),
                productRepository: context.read<ProductRepository>(),
              ),
        ),
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(
          lazy: false,
          create: (context) => ProductCatalog(context.read<ProductRepository>())..load(),
        ),
        ChangeNotifierProvider(
          create: (context) => StatsController(context.read<StatsRepository>()),
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
