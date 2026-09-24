import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/core/widgets/barcode_scanner_view.dart';
import 'package:zapi/core/widgets/cart_item_tile.dart';
import 'package:zapi/core/widgets/primary_button.dart';
import 'package:zapi/core/utils/formatters.dart';
import 'package:zapi/state/cart_controller.dart';
import 'package:zapi/state/product_catalog.dart';

// ============================================================
// RESPONSABLE: Gonza
//
// TAREA:
// Terminar la integracion visual de la pantalla de Scanner del
// cliente. La camara en si (BarcodeScannerView) es otra tarea tuya
// (ver lib/core/widgets/barcode_scanner_view.dart); esta pantalla ya
// esta conectada a ese widget y al carrito compartido.
//
// OBJETIVO:
// Al escanear un codigo, buscar el producto correspondiente (con
// ProductCatalog.findByCode, que hoy busca en datos mock) y agregarlo
// al carrito. Mostrar debajo de la camara el producto recien
// encontrado (o el ultimo agregado) con controles +/- y eliminar, y si
// el carrito tiene productos, mostrar el total y el boton "Pagar".
//
// DEBE UTILIZAR:
// - BarcodeScannerView (camara)
// - CartItemTile, PrimaryButton
// - CartController y ProductCatalog (Provider)
//
// NO DEBE HACER:
// - Implementar el pago real. El boton "Pagar" NO debe llamar a ningun
//   backend ni a Mercado Pago todavia: por ahora solo debe existir
//   visualmente (ver TODO puntual mas abajo, en el onPressed).
//
// POSTERIORMENTE:
// El boton "Pagar" va a disparar el flujo de cobro real (Mercado
// Pago / backend). Cuando eso se implemente, probablemente convenga
// sacar esa logica a un `services/payment_service.dart` nuevo, del
// mismo modo que `ProductService`.
//
// PROMPT PARA IA:
//
// "Estoy trabajando en una app Flutter (Material 3, Provider) llamada
// Zapi. Tengo la pantalla
// lib/features/client/scanner/client_scanner_screen.dart
// (ClientScannerScreen) que usa un widget BarcodeScannerView para
// escanear codigos de barra, un CartController (ChangeNotifier) para
// el carrito compartido, y un ProductCatalog (ChangeNotifier) que
// expone `findByCode(String code)` para buscar productos por codigo
// (hoy busca en datos mock, en el futuro va a pegarle al backend, pero
// eso no me interesa ahora). Quiero que revises/mejores el flujo:
// al detectar un codigo con BarcodeScannerView.onCodeDetected, buscar
// el producto con ProductCatalog.findByCode, si existe agregarlo al
// carrito con CartController.addProduct y mostrar algun feedback breve
// (snackbar) si el codigo no corresponde a ningun producto. Mantene el
// boton 'Pagar' como un boton puramente visual (no debe hacer ninguna
// llamada real), solo agregale un TODO bien visible indicando que ahi
// va a ir la integracion con Mercado Pago/backend."
// ============================================================

/// Pantalla de escaneo del cliente.
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
                Text('Productos escaneados',
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
                    Text('Total de la compra',
                        style: AppTextStyles.sectionTitle),
                    Text(Formatters.currency(cart.total),
                        style: AppTextStyles.screenTitle),
                  ],
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Pagar',
                  icon: Icons.payment,
                  onPressed: () {
                    // TODO(backend/Mercado Pago): este boton todavia NO
                    // realiza ningun pago real. Cuando se integre el
                    // cobro, esto deberia disparar el flujo de Mercado
                    // Pago / backend (crear preferencia de pago, etc.).
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Pago simulado (falta integrar Mercado Pago)',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
