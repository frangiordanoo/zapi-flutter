import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/core/utils/formatters.dart';
import 'package:zapi/core/widgets/primary_button.dart';
import 'package:zapi/core/widgets/secondary_button.dart';
import 'package:zapi/data/models/order.dart';
import 'package:zapi/state/order_controller.dart';
import 'package:zapi/state/product_catalog.dart';

/// Pantalla de "pago en curso" despues de abrir Mercado Pago. Recibe la
/// [Order] como `arguments` de la ruta.
///
/// La app NO puede saber si el pago se acredito: lo confirma el backend por
/// webhook de Mercado Pago (y recien ahi descuenta el stock). Por eso esta
/// pantalla no dice "compra exitosa": explica que hay que completar el pago
/// y permite volver a abrir Mercado Pago.
class ClientOrderConfirmationScreen extends StatelessWidget {
  const ClientOrderConfirmationScreen({super.key, required this.order});

  final Order order;

  Future<void> _reopen(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<OrderController>().openCheckout(order);
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _goHome(BuildContext context) {
    // Si el pago se acredito, el stock cambio: se refresca el catalogo.
    context.read<ProductCatalog>().load();
    Navigator.of(context).pushNamedAndRemoveUntil(
      RouteNames.clientCart,
      (route) => false,
    );
  }

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
                  color: AppColors.warning,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hourglass_top, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text('Completá tu pago', style: AppTextStyles.screenTitle),
              const SizedBox(height: 4),
              Text(
                '${Formatters.dateTime(order.date)} · ${order.paymentMethod} · '
                '${order.status.label}',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Terminá el pago en Mercado Pago. Cuando se acredite, el '
                'comercio lo recibe automáticamente.',
                style: AppTextStyles.body,
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
                  label: 'Abrir Mercado Pago',
                  icon: Icons.open_in_new,
                  onPressed: () => _reopen(context),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SecondaryButton(
                  label: 'Volver al inicio',
                  onPressed: () => _goHome(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
