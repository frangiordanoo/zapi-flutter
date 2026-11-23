import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/core/utils/formatters.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/core/widgets/empty_state.dart';
import 'package:zapi/core/widgets/primary_button.dart';
import 'package:zapi/state/cart_controller.dart';
import 'package:zapi/state/order_controller.dart';

/// Resumen de compra y pago con Mercado Pago.
///
/// Muestra items, precio unitario, subtotales y total. Al confirmar, el
/// [OrderController] le pide al backend el link de pago
/// (`POST /sales/checkout`, que valida stock y calcula el total real) y
/// abre Mercado Pago. Si sale bien se vacia el carrito y se pasa a la
/// pantalla de "pago en curso". Si el backend rechaza la compra (por
/// ejemplo stock insuficiente) se muestra su mensaje y el carrito queda
/// intacto.
class ClientCheckoutScreen extends StatefulWidget {
  const ClientCheckoutScreen({super.key});

  @override
  State<ClientCheckoutScreen> createState() => _ClientCheckoutScreenState();
}

class _ClientCheckoutScreenState extends State<ClientCheckoutScreen> {
  Future<void> _handleConfirm() async {
    final cart = context.read<CartController>();
    final orders = context.read<OrderController>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      final order = await orders.startCheckout(cart.items);
      cart.clear();
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        RouteNames.clientOrderConfirmation,
        arguments: order,
      );
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final isProcessing = context.watch<OrderController>().isProcessing;

    return Scaffold(
      appBar: const AppHeader(title: 'Resumen de compra', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: cart.isEmpty
                    ? const EmptyState(
                        icon: Icons.shopping_cart_outlined,
                        message: 'Tu carrito está vacío.',
                      )
                    : ListView(
                        children: [
                          const Text('Productos', style: AppTextStyles.sectionTitle),
                          const SizedBox(height: 8),
                          ...cart.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.product.name, style: AppTextStyles.body),
                                        Text(
                                          'x${item.quantity} · '
                                          '${Formatters.currency(item.product.price)} c/u',
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
                          ),
                          const Divider(height: 32, color: AppColors.border),
                          const Text('Medio de pago', style: AppTextStyles.sectionTitle),
                          const SizedBox(height: 8),
                          const ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.payments_outlined, color: AppColors.primary),
                            title: Text('Mercado Pago', style: AppTextStyles.body),
                            subtitle: Text(
                              'Vas a completar el pago en Mercado Pago.',
                              style: AppTextStyles.caption,
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
              if (isProcessing)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Preparando el pago…', style: AppTextStyles.caption),
                  ],
                )
              else
                PrimaryButton(
                  label: 'Pagar con Mercado Pago',
                  icon: Icons.open_in_new,
                  onPressed: cart.isEmpty ? null : _handleConfirm,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
