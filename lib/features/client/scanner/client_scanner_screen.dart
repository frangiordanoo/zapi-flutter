import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/core/widgets/barcode_scanner_view.dart';
import 'package:zapi/core/widgets/cart_item_tile.dart';
import 'package:zapi/core/widgets/primary_button.dart';
import 'package:zapi/core/utils/formatters.dart';
import 'package:zapi/state/cart_controller.dart';
import 'package:zapi/state/product_catalog.dart';

/// Pantalla de escaneo del cliente.
///
/// Usa [BarcodeScannerView] (camara real) para detectar un codigo,
/// busca el producto con `ProductCatalog.findByCode` y lo agrega al
/// carrito compartido (`CartController`). El boton "Pagar" es
/// intencionalmente solo visual: todavia falta integrar un medio de
/// pago real (Mercado Pago / backend), ver el TODO en su `onPressed`.
class ClientScannerScreen extends StatefulWidget {
  const ClientScannerScreen({super.key});

  @override
  State<ClientScannerScreen> createState() => _ClientScannerScreenState();
}

class _ClientScannerScreenState extends State<ClientScannerScreen> {
  String? _statusText;

  Future<void> _handleCodeDetected(String code) async {
    final catalog = context.read<ProductCatalog>();
    final cart = context.read<CartController>();

    final product = await catalog.findByCode(code);

    if (!mounted) return;

    if (product == null) {
      setState(() => _statusText = 'No se encontró ningún producto');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Código $code no reconocido')),
      );
      return;
    }

    cart.addProduct(product);
    setState(() => _statusText = 'Agregado: ${product.name}');
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();

    return Scaffold(
      appBar: const AppHeader(title: 'Escanear', showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BarcodeScannerView(
                statusText: _statusText,
                onCodeDetected: _handleCodeDetected,
              ),
              const SizedBox(height: 20),
              if (cart.items.isNotEmpty) ...[
                const Text('Productos escaneados',
                    style: AppTextStyles.sectionTitle),
                const SizedBox(height: 8),
                ...cart.items.map(
                  (item) => CartItemTile(
                    item: item,
                    onIncrement: () => cart.increment(item.product.id),
                    onDecrement: () => cart.decrement(item.product.id),
                    onRemove: () => cart.removeProduct(item.product.id),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total de la compra',
                        style: AppTextStyles.sectionTitle),
                    Text(Formatters.currency(cart.total),
                        style: AppTextStyles.screenTitle),
                  ],
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Pagar',
                  icon: Icons.payment,
                  onPressed: () =>
                      Navigator.pushNamed(context, RouteNames.clientCheckout),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
