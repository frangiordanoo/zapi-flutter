import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/core/widgets/cart_item_tile.dart';
import 'package:zapi/core/widgets/empty_state.dart';
import 'package:zapi/core/widgets/primary_button.dart';
import 'package:zapi/core/widgets/secondary_button.dart';
import 'package:zapi/core/utils/formatters.dart';
import 'package:zapi/state/cart_controller.dart';

/// Pantalla principal del cliente: el carrito.
///
/// Lee y modifica el carrito siempre a traves de [CartController]
/// (nunca con estado local), para que quede sincronizado con Scanner y
/// Product List, que comparten la misma instancia via Provider.
class ClientCartScreen extends StatelessWidget {
  const ClientCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();

    return Scaffold(
      appBar: const AppHeader(title: 'Mi carrito'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: cart.isEmpty
                    ? const EmptyState(
                        icon: Icons.shopping_cart_outlined,
                        message: '¡Tu carrito está vacío!',
                      )
                    : ListView.builder(
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) {
                          final item = cart.items[index];
                          return CartItemTile(
                            item: item,
                            onIncrement: () =>
                                cart.increment(item.product.id),
                            onDecrement: () =>
                                cart.decrement(item.product.id),
                            onRemove: () =>
                                cart.removeProduct(item.product.id),
                          );
                        },
                      ),
              ),
              if (!cart.isEmpty) ...[
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: AppTextStyles.sectionTitle),
                    Text(Formatters.currency(cart.total),
                        style: AppTextStyles.screenTitle),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Ver lista',
                      icon: Icons.list_alt,
                      onPressed: () => Navigator.pushNamed(
                          context, RouteNames.clientProductList),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Escanear',
                      icon: Icons.qr_code_scanner,
                      onPressed: () => Navigator.pushNamed(
                          context, RouteNames.clientScanner),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
