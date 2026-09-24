import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/core/widgets/barcode_scanner_view.dart';
import 'package:zapi/core/widgets/primary_button.dart';
import 'package:zapi/models/product.dart';
import 'package:zapi/state/product_catalog.dart';

// ============================================================
// RESPONSABLE: Gonza
//
// TAREA:
// Pantalla de carga de un producto nuevo, reutilizando el componente
// de camara (BarcodeScannerView) para completar el codigo de barras.
//
// OBJETIVO:
// Detectar el codigo (hoy simulado, ver BarcodeScannerView), mostrar el
// estado ("No se detectó ningún código" / "Código detectado: ..."), y
// permitir cargar nombre, precio y stock inicial. Al presionar "Subir",
// agregar el producto a la lista mock local (ProductCatalog) sin
// llamar al backend.
//
// DEBE UTILIZAR:
// - AppHeader, BarcodeScannerView, PrimaryButton
// - ProductCatalog (Provider) para crear el producto
//
// NO DEBE HACER:
// - Ningun POST real al backend.
//
// POSTERIORMENTE:
// El boton "Subir" va a hacer un POST /products real. Cuando eso pase,
// alcanza con reemplazar la llamada a
// `ProductCatalog.addProduct` (que hoy usa MockProductService) por la
// implementacion real dentro de `ApiProductService`, sin tocar esta
// pantalla.
//
// PROMPT PARA IA:
//
// "Estoy trabajando en una app Flutter (Material 3, Provider) llamada
// Zapi. Tengo la pantalla
// lib/features/admin/add_product/admin_add_product_screen.dart
// (AdminAddProductScreen) que usa BarcodeScannerView para detectar un
// codigo de barras (guardado en un String? de estado local) y un
// formulario simple (nombre, precio, stock) con un boton 'Subir' que
// arma un objeto Product y llama a
// context.read<ProductCatalog>().addProduct(product) para agregarlo a
// los datos mock. Quiero que agregues validaciones basicas al
// formulario (campos obligatorios, precio y stock numericos) usando
// Form + TextFormField + validator, y que muestres un SnackBar de
// confirmacion cuando el producto se agrega correctamente, limpiando
// el formulario despues. No agregues ninguna llamada HTTP real."
// ============================================================

/// Pantalla de carga de un producto nuevo por parte del administrador.
class AdminAddProductScreen extends StatefulWidget {
  const AdminAddProductScreen({super.key});

  @override
  State<AdminAddProductScreen> createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> {
  String? _detectedCode;
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _handleUpload() async {
    final price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0;
    final stock = int.tryParse(_stockController.text) ?? 0;

    if (_nameController.text.trim().isEmpty || _detectedCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completá el nombre y escaneá un código')),
      );
      return;
    }

    final product = Product(
      id: 0, // MockProductService asigna el id real al crear.
      code: _detectedCode!,
      name: _nameController.text.trim(),
      price: price,
      stock: stock,
      createdAt: DateTime.now(),
      category: 'Sin categoría',
    );

    await context.read<ProductCatalog>().addProduct(product);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto agregado')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Carga de producto', showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BarcodeScannerView(
                onCodeDetected: (code) => setState(() => _detectedCode = code),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _detectedCode == null
                      ? 'No se detectó ningún código'
                      : 'Código detectado:\n$_detectedCode',
                  style: AppTextStyles.bodyBold,
                ),
              ),
              const SizedBox(height: 20),
              const Text('Nombre', style: AppTextStyles.bodyBold),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Nombre del producto'),
              ),
              const SizedBox(height: 16),
              const Text('Precio', style: AppTextStyles.bodyBold),
              const SizedBox(height: 6),
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(hintText: 'Precio (\$)'),
              ),
              const SizedBox(height: 16),
              const Text('Stock', style: AppTextStyles.bodyBold),
              const SizedBox(height: 6),
              TextField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Cantidad inicial'),
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: 'Subir', onPressed: _handleUpload),
            ],
          ),
        ),
      ),
    );
  }
}
