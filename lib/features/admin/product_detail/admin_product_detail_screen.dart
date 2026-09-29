import 'package:flutter/material.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/utils/formatters.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/mock/mock_stats.dart';
import 'package:zapi/models/product.dart';

/// Vista de detalle de un producto para el administrador: datos
/// completos + un mini historial de ventas mock de ese producto.
///
/// Recibe el [Product] a mostrar como `arguments` de la ruta.
class AdminProductDetailScreen extends StatelessWidget {
  const AdminProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final unitsSold = MockStats.topProducts[product.name] ?? 0;

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
                  _InfoRow(label: 'Alta', value: Formatters.date(product.createdAt)),
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
                  const Text('Unidades vendidas (mock)', style: AppTextStyles.body),
                  Text('$unitsSold', style: AppTextStyles.price),
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
