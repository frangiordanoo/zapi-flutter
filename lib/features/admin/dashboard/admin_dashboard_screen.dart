import 'package:flutter/material.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/core/utils/formatters.dart';
import 'package:zapi/features/admin/dashboard/widgets/stats_bar_chart.dart';
import 'package:zapi/mock/mock_products.dart';
import 'package:zapi/mock/mock_stats.dart';

/// Dashboard de estadisticas del administrador (pantalla por defecto
/// luego del login).
///
/// Los datos vienen de [MockStats] y de [mockProducts] (para el listado
/// de "poco stock"). El dia que exista un endpoint real de estadisticas,
/// lo ideal es crear un `StatsService` con el mismo patron que
/// `ProductService` y reemplazar estas referencias por ese servicio.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lowStockProducts =
        mockProducts.where((p) => !p.isDeleted && p.stock <= 5).toList();

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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Ventas totales',
                    value: Formatters.currency(MockStats.totalSales),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Ventas de hoy',
                    value: Formatters.currency(MockStats.todaySales),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Cantidad de ventas',
                    value: '${MockStats.totalOrders}',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Producto más vendido',
                    value: MockStats.bestSellingProduct,
                    small: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Productos más vendidos', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 12),
            const StatsBarChart(data: MockStats.topProducts),
            const SizedBox(height: 24),
            const Text('Día de la semana con más ventas',
                style: AppTextStyles.sectionTitle),
            const SizedBox(height: 12),
            const StatsBarChart(data: MockStats.salesByWeekday),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Productos con poco stock',
                    style: AppTextStyles.sectionTitle),
                Text('${lowStockProducts.length}', style: AppTextStyles.price),
              ],
            ),
            const SizedBox(height: 8),
            if (lowStockProducts.isEmpty)
              const Text('No hay productos con poco stock.',
                  style: AppTextStyles.caption)
            else
              ...lowStockProducts.map(
                (p) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(p.name, style: AppTextStyles.body),
                      Text(
                        'Stock: ${p.stock}',
                        style: AppTextStyles.bodyBold.copyWith(
                          color: p.stock == 0
                              ? AppColors.danger
                              : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
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
