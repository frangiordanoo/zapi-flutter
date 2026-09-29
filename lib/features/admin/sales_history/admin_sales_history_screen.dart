import 'package:flutter/material.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/utils/formatters.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/mock/mock_sales.dart';

/// Historial de ventas del administrador (datos mock, ver
/// lib/mock/mock_sales.dart).
class AdminSalesHistoryScreen extends StatelessWidget {
  const AdminSalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Historial de ventas', showBackButton: true),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: mockSales.length,
          separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
          itemBuilder: (context, index) {
            final sale = mockSales[index];
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
                    child: const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
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
