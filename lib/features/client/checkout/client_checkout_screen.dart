import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/utils/formatters.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/core/widgets/primary_button.dart';
import 'package:zapi/state/cart_controller.dart';

/// Resumen de compra antes de confirmar el pago.
///
/// Es puramente visual: no integra ningún medio de pago real todavía
/// (ver TODO en el botón "Confirmar pago").
class ClientCheckoutScreen extends StatefulWidget {
  const ClientCheckoutScreen({super.key});

  @override
  State<ClientCheckoutScreen> createState() => _ClientCheckoutScreenState();
}

class _ClientCheckoutScreenState extends State<ClientCheckoutScreen> {
  String _paymentMethod = 'Mercado Pago';

  static const _methods = ['Mercado Pago', 'Tarjeta', 'Efectivo'];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();

    return Scaffold(
      appBar: const AppHeader(title: 'Resumen de compra', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const Text('Productos', style: AppTextStyles.sectionTitle),
                    const SizedBox(height: 8),
                    ...cart.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text('${item.product.name} x${item.quantity}',
                                  style: AppTextStyles.body),
                            ),
                            Text(Formatters.currency(item.subtotal), style: AppTextStyles.bodyBold),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 32, color: AppColors.border),
                    const Text('Medio de pago', style: AppTextStyles.sectionTitle),
                    const SizedBox(height: 8),
                    RadioGroup<String>(
                      groupValue: _paymentMethod,
                      onChanged: (value) => setState(() => _paymentMethod = value!),
                      child: Column(
                        children: _methods
                            .map(
                              (method) => RadioListTile<String>(
                                contentPadding: EdgeInsets.zero,
                                value: method,
                                title: Text(method, style: AppTextStyles.body),
                                activeColor: AppColors.primary,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24, color: AppColors.border),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: AppTextStyles.sectionTitle),
                  Text(Formatters.currency(cart.total), style: AppTextStyles.screenTitle),
                ],
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Confirmar pago',
                icon: Icons.check_circle_outline,
                onPressed: () {
                  // TODO(backend/Mercado Pago): esto todavia NO procesa
                  // ningun pago real. Cuando se integre, aca deberia ir
                  // la llamada al medio de pago elegido.
                  cart.clear();
                  Navigator.pushReplacementNamed(context, RouteNames.clientOrderConfirmation);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
