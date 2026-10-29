import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/utils/formatters.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/core/widgets/empty_state.dart';
import 'package:zapi/core/widgets/error_state.dart';
import 'package:zapi/features/admin/stats/stats_controller.dart';

/// Historial de ventas del administrador. Lee las mismas ventas
/// simuladas que el dashboard (`StatsController`), asi que los totales
/// siempre coinciden con las tarjetas y los graficos.
class AdminSalesHistoryScreen extends StatelessWidget {
  const AdminSalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StatsController>();
    final sales = controller.stats?.sales;

    return Scaffold(
      appBar: const AppHeader(title: 'Historial de ventas', showBackButton: true),
      body: SafeArea(
        child: sales == null
            ? (controller.errorMessage != null && !controller.isLoading
                ? ErrorState(message: controller.errorMessage!, onRetry: controller.load)
                : const Center(child: CircularProgressIndicator()))
            : sales.isEmpty
                ? const EmptyState(
                    icon: Icons.receipt_long_outlined,
                    message: 'Todavía no hay ventas registradas.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: sales.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final sale = sales[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.receipt_long_outlined,
                                  color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Pedido #${sale.id}', style: AppTextStyles.bodyBold),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${sale.itemsCount} productos · ${sale.paymentMethod} · '
                                    '${Formatters.date(sale.date)}',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                            Text(Formatters.currency(sale.total), style: AppTextStyles.price),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
