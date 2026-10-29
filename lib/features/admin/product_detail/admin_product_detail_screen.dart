import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/utils/formatters.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/data/models/product.dart';
import 'package:zapi/features/admin/stats/stats_controller.dart';

/// Vista de detalle de un producto para el administrador: datos
/// completos + las unidades vendidas segun las ventas simuladas.
///
/// Recibe el [Product] a mostrar como `arguments` de la ruta.
class AdminProductDetailScreen extends StatelessWidget {
  const AdminProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsController>().stats;
    final unitsSold = stats == null ? '—' : '${stats.unitsSoldOf(product.code)}';

    return Scaffold(
      appBar: AppHeader(title: product.name, showBackButton: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: AppTextStyles.screenTitle),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Código de barras', value: product.code),
                  _InfoRow(label: 'Categoría', value: product.category),
                  _InfoRow(label: 'Precio', value: Formatters.currency(product.price)),
                  _InfoRow(
                    label: 'Stock actual',
                    value: '${product.stock}',
                    valueColor: product.stock == 0 ? AppColors.danger : null,
                  ),
                  _InfoRow(
                    label: 'Alta',
                    value: product.createdAt == null
                        ? '—'
                        : Formatters.date(product.createdAt!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Ventas', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text('Unidades vendidas (simuladas, 7 días)',
                        style: AppTextStyles.body),
                  ),
                  Text(unitsSold, style: AppTextStyles.price),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption),
          Text(
            value,
            style: AppTextStyles.bodyBold.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}
