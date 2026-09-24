import 'package:flutter/material.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/core/utils/formatters.dart';
import 'package:zapi/features/admin/dashboard/widgets/stats_bar_chart.dart';
import 'package:zapi/mock/mock_products.dart';
import 'package:zapi/mock/mock_stats.dart';

// ============================================================
// RESPONSABLE: Facundo Palavecino
//
// TAREA:
// Implementar la pantalla de estadisticas del administrador (pantalla
// por defecto luego del login).
//
// OBJETIVO:
// Mostrar estadisticas de ventas utilizando inicialmente datos mock
// (lib/mock/mock_stats.dart): ventas totales, cantidad de ventas,
// producto mas vendido, ventas del dia, grafico de ventas por dia de
// semana y ranking de productos mas vendidos. Tambien se muestra un
// listado rapido de "productos con poco stock" usando el catalogo real
// de productos (mockProducts).
//
// DEBE UTILIZAR:
// - AppHeader
// - StatsBarChart (lib/features/admin/dashboard/widgets/stats_bar_chart.dart)
// - MockStats (lib/mock/mock_stats.dart)
//
// NO DEBE HACER:
// - Llamadas al backend, autenticacion, ni logica de servidor.
//
// POSTERIORMENTE:
// Los datos de MockStats deberan reemplazarse por la respuesta de un
// endpoint de estadisticas real (por ejemplo GET /stats/summary). Lo
// ideal es crear un `StatsService` con el mismo patron que
// `ProductService` cuando eso pase.
//
// PROMPT PARA IA:
//
// "Estoy trabajando en una app Flutter (Material 3) llamada Zapi.
// Tengo la pantalla
// lib/features/admin/dashboard/admin_dashboard_screen.dart
// (AdminDashboardScreen) que muestra estadisticas de ventas usando
// datos fijos de una clase MockStats (lib/mock/mock_stats.dart) y un
// widget StatsBarChart (lib/features/admin/dashboard/widgets/stats_bar_chart.dart)
// basado en fl_chart. Quiero que mejores el diseño visual de esta
// pantalla (tarjetas de resumen, orden de la informacion, espaciados)
// manteniendo AppColors/AppTextStyles para los estilos y sin conectar
// ningun backend: los datos siguen viniendo de MockStats. Si te parece
// que falta alguna metrica util para un kiosco (por ejemplo ticket
// promedio), podes agregarla a MockStats con un valor de ejemplo."
// ============================================================

/// Dashboard de estadisticas del administrador (pantalla por defecto
/// luego del login).
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lowStockProducts =
        mockProducts.where((p) => !p.isDeleted && p.stock <= 5).toList();

    return Scaffold(
      appBar: const AppHeader(title: 'Estadísticas', light: true),
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
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Cantidad de ventas',
                    value: '${MockStats.totalOrders}',
                  ),
                ),
                const SizedBox(width: 12),
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
            Text('Productos más vendidos', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 12),
            StatsBarChart(data: MockStats.topProducts),
            const SizedBox(height: 24),
            Text('Día de la semana con más ventas',
                style: AppTextStyles.sectionTitle),
            const SizedBox(height: 12),
            StatsBarChart(data: MockStats.salesByWeekday),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Productos con poco stock',
                    style: AppTextStyles.sectionTitle),
                Text('${lowStockProducts.length}', style: AppTextStyles.price),
              ],
            ),
            const SizedBox(height: 8),
            if (lowStockProducts.isEmpty)
              Text('No hay productos con poco stock.',
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
