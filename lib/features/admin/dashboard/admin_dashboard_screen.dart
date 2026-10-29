import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/utils/formatters.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/core/widgets/error_state.dart';
import 'package:zapi/data/models/sales_stats.dart';
import 'package:zapi/features/admin/dashboard/widgets/stats_bar_chart.dart';
import 'package:zapi/features/admin/stats/stats_controller.dart';
import 'package:zapi/state/product_catalog.dart';

/// Dashboard de estadisticas del administrador (pantalla por defecto
/// luego del login).
///
/// Las ventas son SIMULADAS (ver `MockSalesDataSource`) pero los productos
/// (nombres, precios, stock) son los reales de la API. Todo se lee desde
/// `StatsController` y `ProductCatalog`; esta pantalla no calcula ni
/// consulta nada por su cuenta.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const _weekdays = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = context.read<StatsController>();
      if (controller.stats == null) controller.load();
    });
  }

  Future<void> _refresh() async {
    final catalog = context.read<ProductCatalog>();
    final controller = context.read<StatsController>();
    await catalog.load();
    await controller.load();
  }

  /// Los nombres largos no entran bajo cada barra.
  String _shortLabel(String name) =>
      name.length <= 9 ? name : '${name.substring(0, 8).trimRight()}…';

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<ProductCatalog>();
    final controller = context.watch<StatsController>();
    final stats = controller.stats;

    return Scaffold(
      appBar: AppHeader(
        title: 'Estadísticas',
        light: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
              tooltip: 'Historial de ventas',
              onPressed: () => Navigator.pushNamed(context, RouteNames.adminSalesHistory),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
              tooltip: 'Notificaciones',
              onPressed: () => Navigator.pushNamed(context, RouteNames.adminNotifications),
            ),
            IconButton(
              icon: const Icon(Icons.person_outline, color: AppColors.primary),
              tooltip: 'Perfil',
              onPressed: () => Navigator.pushNamed(context, RouteNames.adminProfile),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: stats == null
            ? _buildWithoutStats(controller)
            : RefreshIndicator(
                onRefresh: _refresh,
                child: _buildContent(stats, catalog),
              ),
      ),
    );
  }

  Widget _buildWithoutStats(StatsController controller) {
    if (controller.errorMessage != null && !controller.isLoading) {
      return ErrorState(
        message: 'No se pudieron cargar las estadísticas. ${controller.errorMessage}',
        onRetry: controller.load,
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildContent(SalesStats stats, ProductCatalog catalog) {
    final lowStockProducts = catalog.products.where((p) => p.stock <= 5).toList()
      ..sort((a, b) => a.stock.compareTo(b.stock));
    final best = stats.bestSeller;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Ventas simuladas · últimos 7 días',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Ventas totales',
                value: Formatters.currency(stats.totalSales),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Ventas de hoy',
                value: Formatters.currency(stats.todaySales),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Cantidad de ventas',
                value: '${stats.totalOrders}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Producto más vendido',
                value: best?.product.name ?? 'Sin ventas',
                small: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Productos más vendidos', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 12),
        if (stats.topProducts.isEmpty)
          const Text('Todavía no hay ventas en el período.', style: AppTextStyles.caption)
        else
          StatsBarChart(
            entries: [
              for (final item in stats.topProducts.take(5))
                MapEntry(_shortLabel(item.product.name), item.units),
            ],
          ),
        const SizedBox(height: 24),
        const Text('Día de la semana con más ventas', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 12),
        StatsBarChart(
          entries: [
            for (final day in stats.daily)
              MapEntry(_weekdays[day.day.weekday - 1], day.total),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Productos con poco stock', style: AppTextStyles.sectionTitle),
            Text('${lowStockProducts.length}', style: AppTextStyles.price),
          ],
        ),
        const SizedBox(height: 8),
        if (catalog.products.isEmpty && catalog.errorMessage != null)
          const Text('No se pudo cargar el stock.', style: AppTextStyles.caption)
        else if (lowStockProducts.isEmpty)
          const Text('No hay productos con poco stock.', style: AppTextStyles.caption)
        else
          ...lowStockProducts.map(
            (p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(p.name, style: AppTextStyles.body, maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  Text(
                    'Stock: ${p.stock}',
                    style: AppTextStyles.bodyBold.copyWith(
                      color: p.stock == 0 ? AppColors.danger : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.small = false,
  });

  final String label;
  final String value;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 6),
          Text(
            value,
            style: small ? AppTextStyles.bodyBold : AppTextStyles.screenTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
