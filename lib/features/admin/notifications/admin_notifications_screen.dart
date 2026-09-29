import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/core/widgets/empty_state.dart';
import 'package:zapi/state/product_catalog.dart';

/// Alertas de stock bajo, como pantalla completa (version expandida de
/// la lista corta que ya se muestra en el Dashboard).
class AdminNotificationsScreen extends StatelessWidget {
  const AdminNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<ProductCatalog>();
    final alerts = catalog.products.where((p) => p.stock <= 5).toList()
      ..sort((a, b) => a.stock.compareTo(b.stock));

    return Scaffold(
      appBar: const AppHeader(title: 'Notificaciones', showBackButton: true),
      body: SafeArea(
        child: alerts.isEmpty
            ? const EmptyState(
                icon: Icons.notifications_none,
                message: 'No hay alertas de stock por el momento.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: alerts.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, index) {
                  final product = alerts[index];
                  final isOutOfStock = product.stock == 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Icon(
                          isOutOfStock ? Icons.error_outline : Icons.warning_amber_rounded,
                          color: isOutOfStock ? AppColors.danger : AppColors.warning,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name, style: AppTextStyles.bodyBold),
                              Text(
                                isOutOfStock
                                    ? 'Sin stock'
                                    : 'Quedan ${product.stock} unidades',
                                style: AppTextStyles.caption.copyWith(
                                  color: isOutOfStock ? AppColors.danger : AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
