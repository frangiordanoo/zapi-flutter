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

/// Resumen de compra y confirmacion del pago.
///
/// Muestra items, precio unitario, subtotales y total. Al confirmar, el
/// [OrderController] valida el carrito (stock incluido), simula el pago y
/// crea la orden; si sale bien se vacia el carrito y se muestra la
/// confirmacion. El pago es una simulacion: no hay pasarela real todavia.
class ClientCheckoutScreen extends StatefulWidget {
  const ClientCheckoutScreen({super.key});

  @override
  State<ClientCheckoutScreen> createState() => _ClientCheckoutScreenState();
}

class _ClientCheckoutScreenState extends State<ClientCheckoutScreen> {
  String _paymentMethod = 'Mercado Pago';

  static const _methods = ['Mercado Pago', 'Tarjeta', 'Efectivo'];

  Future<void> _handleConfirm() async {
    final cart = context.read<CartController>();
    final orders = context.read<OrderController>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      final order = await orders.placeOrder(
        items: cart.items,
        paymentMethod: _paymentMethod,
      );
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
                          RadioGroup<String>(
                            groupValue: _paymentMethod,
                            onChanged: (value) {
                              if (!isProcessing) setState(() => _paymentMethod = value!);
                            },
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
              if (isProcessing)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Procesando pago…', style: AppTextStyles.caption),
                  ],
                )
              else
                PrimaryButton(
                  label: 'Confirmar pago',
                  icon: Icons.check_circle_outline,
                  onPressed: cart.isEmpty ? null : _handleConfirm,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
