import 'package:flutter/material.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/utils/formatters.dart';
import 'package:zapi/core/widgets/primary_button.dart';
import 'package:zapi/data/models/order.dart';

/// Confirmacion de la compra: muestra la [Order] generada (numero, fecha,
/// items, total, medio de pago y estado). Recibe la orden como `arguments`
/// de la ruta.
class ClientOrderConfirmationScreen extends StatelessWidget {
  const ClientOrderConfirmationScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text('¡Gracias por tu compra!', style: AppTextStyles.screenTitle),
              const SizedBox(height: 4),
              Text('Pedido #${order.id}', style: AppTextStyles.bodyBold),
              const SizedBox(height: 4),
              Text(
                '${Formatters.dateTime(order.date)} · ${order.paymentMethod} · '
                '${order.status.label}',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              Expanded(
                child: ListView(
                  children: [
                    for (final item in order.items)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.productName, style: AppTextStyles.body),
                                  Text(
                                    'x${item.quantity} · '
                                    '${Formatters.currency(item.unitPrice)} c/u',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                            Text(Formatters.currency(item.subtotal),
                                style: AppTextStyles.bodyBold),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(color: AppColors.border),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: AppTextStyles.sectionTitle),
                  Text(Formatters.currency(order.total), style: AppTextStyles.screenTitle),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Volver al inicio',
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                    RouteNames.clientCart,
                    (route) => false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
