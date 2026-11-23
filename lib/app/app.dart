import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/router/app_router.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_theme.dart';
import 'package:zapi/core/constants/app_constants.dart';
import 'package:zapi/core/network/api_client.dart';
import 'package:zapi/core/network/session_store.dart';
import 'package:zapi/data/mocks/mock_sales_data_source.dart';
import 'package:zapi/data/repositories/order_repository.dart';
import 'package:zapi/data/repositories/product_repository.dart';
import 'package:zapi/data/repositories/stats_repository.dart';
import 'package:zapi/data/services/auth_service.dart';
import 'package:zapi/data/services/checkout_service.dart';
import 'package:zapi/data/services/http_product_service.dart';
import 'package:zapi/data/services/http_sales_data_source.dart';
import 'package:zapi/data/services/sales_data_source.dart';
import 'package:zapi/features/admin/stats/stats_controller.dart';
import 'package:zapi/state/auth_controller.dart';
import 'package:zapi/state/cart_controller.dart';
import 'package:zapi/state/order_controller.dart';
import 'package:zapi/state/product_catalog.dart';
import 'package:zapi/state/sales_history_controller.dart';

/// Widget raiz de la app: arma las dependencias (API -> servicio ->
/// repositorio -> estado) y configura el `MaterialApp`.
///
/// Todos los servicios comparten UN [ApiClient], que manda el token de la
/// sesion de administrador (si existe) en cada peticion.
///
/// Los repositorios se pueden inyectar desde afuera (los tests lo usan
/// para no tocar la red); en la app real se crean los de produccion.
///
/// De donde sale cada dato del administrador:
/// - Productos, stock, login y pago: API real.
/// - Historial de ventas: API real (`GET /sales/history`).
/// - Estadisticas (dashboard): SIMULADAS. El backend todavia no tiene
///   estadisticas (el endpoint `/sales/statistics` existe pero no funciona),
///   asi que siguen con ventas de ejemplo hasta que el backend las ofrezca.
class ZapiApp extends StatelessWidget {
  const ZapiApp({
    super.key,
    this.productRepository,
    this.statsRepository,
    this.salesHistorySource,
    this.authService,
  });

  final ProductRepository? productRepository;
  final StatsRepository? statsRepository;
  final SalesDataSource? salesHistorySource;
  final AuthService? authService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SessionStore>(create: (_) => SessionStore()),
        Provider<ApiClient>(
          create: (context) => ApiClient(session: context.read<SessionStore>()),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthController(
            authService ?? HttpAuthService(context.read<ApiClient>()),
            context.read<SessionStore>(),
          ),
        ),
        Provider<ProductRepository>(
          create: (context) =>
              productRepository ??
              ProductRepository(HttpProductService(context.read<ApiClient>())),
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
          create: (context) => ProductCatalog(
            context.read<ProductRepository>(),
            isAdmin: () => context.read<AuthController>().isAdmin,
          )..load(),
        ),
        ChangeNotifierProvider(
          create: (context) => StatsController(context.read<StatsRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => SalesHistoryController(
            salesHistorySource ?? HttpSalesDataSource(context.read<ApiClient>()),
          ),
        ),
        Provider<OrderRepository>(
          create: (context) => OrderRepository(
            HttpCheckoutService(context.read<ApiClient>()),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => OrderController(context.read<OrderRepository>()),
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
