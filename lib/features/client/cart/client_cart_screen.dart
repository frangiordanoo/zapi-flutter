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

// ============================================================
// RESPONSABLE: Misa
//
// TAREA:
// Esta es la pantalla principal del cliente (el carrito). Hoy ya
// funciona visualmente con datos mock/estado compartido
// (CartController), pero es el punto de partida para pulir la
// experiencia de "Client Home".
//
// OBJETIVO:
// Mostrar el carrito de compras actual, permitir modificar cantidades y
// eliminar productos, y navegar a Scanner / Product List.
//
// DEBE UTILIZAR:
// - AppHeader, CartItemTile, EmptyState, PrimaryButton, SecondaryButton
// - CartController (context.watch<CartController>()) para leer el
//   carrito. NO manejar el carrito con estado local de esta pantalla.
//
// NO DEBE HACER:
// - Llamadas al backend.
// - Logica de pago real (el boton Pagar vive en Scanner, no aca, ver
//   ese archivo).
//
// PROMPT PARA IA:
//
// "Estoy trabajando en una app Flutter (Material 3, Provider para
// estado) llamada Zapi. Tengo la pantalla
// lib/features/client/cart/client_cart_screen.dart (ClientCartScreen)
// que muestra el carrito de compras usando un CartController
// (ChangeNotifier en lib/state/cart_controller.dart) leido con
// `context.watch<CartController>()`. Quiero que la mejores
// visualmente (animaciones al agregar/quitar items, mejor manejo del
// scroll, etc.) sin cambiar la forma en la que se lee/modifica el
// estado del carrito (siempre a traves de CartController), y sin tocar
// la navegacion hacia Scanner (RouteNames.clientScanner) ni Product
// List (RouteNames.clientProductList)."
// ============================================================

/// Pantalla principal del cliente: el carrito.
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
