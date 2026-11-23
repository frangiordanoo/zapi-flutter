import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/utils/formatters.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/core/widgets/empty_state.dart';
import 'package:zapi/core/widgets/error_state.dart';
import 'package:zapi/data/models/sale.dart';
import 'package:zapi/data/models/sales_history_day.dart';
import 'package:zapi/state/sales_history_controller.dart';

/// Historial de ventas del administrador: las ventas PAGADAS reales
/// (`GET /sales/history`), agrupadas por dia (Hoy / Ayer / fecha) con el
/// total de cada dia. Cada compra muestra la hora de pago, el total y los
/// productos con el precio al momento de vender.
class AdminSalesHistoryScreen extends StatefulWidget {
  const AdminSalesHistoryScreen({super.key});

  @override
  State<AdminSalesHistoryScreen> createState() => _AdminSalesHistoryScreenState();
}

class _AdminSalesHistoryScreenState extends State<AdminSalesHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Se recarga cada vez que se entra, como hace el frontend web.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SalesHistoryController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SalesHistoryController>();
    final days = controller.days;

    return Scaffold(
      appBar: const AppHeader(title: 'Historial de ventas', showBackButton: true),
      body: SafeArea(
        child: days == null
            ? (controller.errorMessage != null && !controller.isLoading
                ? ErrorState(
                    message: 'No pudimos cargar el historial de ventas. '
                        '${controller.errorMessage}',
                    onRetry: controller.load,
                  )
                : const Center(child: CircularProgressIndicator()))
            : RefreshIndicator(
                onRefresh: controller.load,
                child: days.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          EmptyState(
                            icon: Icons.receipt_long_outlined,
                            message: 'Todavía no hay ventas registradas.',
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: days.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) => _DaySection(day: days[index]),
                      ),
              ),
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({required this.day});

  final SalesHistoryDay day;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.primaryLight,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(day.label(DateTime.now()), style: AppTextStyles.sectionTitle),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${day.totalSales} ${day.totalSales == 1 ? 'venta' : 'ventas'}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                for (final sale in day.sales) ...[
                  _SaleCard(sale: sale),
                  const SizedBox(height: 12),
                ],
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total del día', style: AppTextStyles.bodyBold),
                    Text(Formatters.currency(day.totalAmount),
                        style: AppTextStyles.price),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SaleCard extends StatelessWidget {
  const _SaleCard({required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Detalle de compra', style: AppTextStyles.bodyBold),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.schedule,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('${SalesHistoryDay.clock(sale.date)} hs',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
              Text(Formatters.currency(sale.total), style: AppTextStyles.price),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          for (final item in sale.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.productName ?? item.productCode,
                      style: AppTextStyles.body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${item.quantity} x ${Formatters.currency(item.unitPrice ?? 0)}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
