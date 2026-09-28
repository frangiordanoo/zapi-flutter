import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/core/widgets/barcode_scanner_view.dart';
import 'package:zapi/core/widgets/primary_button.dart';
import 'package:zapi/models/product.dart';
import 'package:zapi/state/product_catalog.dart';

/// Pantalla de carga de un producto nuevo por parte del administrador.
///
/// El codigo de barras se completa con [BarcodeScannerView] (camara real
/// con `mobile_scanner`, con boton de respaldo para simular el escaneo).
/// El producto se agrega a [ProductCatalog], que hoy trabaja contra
/// datos mock; el dia que exista backend, esto se resuelve solo
/// reemplazando `MockProductService` por un `ApiProductService`.
class AdminAddProductScreen extends StatefulWidget {
  const AdminAddProductScreen({super.key});

  @override
  State<AdminAddProductScreen> createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> {
  final _formKey = GlobalKey<FormState>();
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
    if (_detectedCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escaneá o simulá un código de barras primero')),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final product = Product(
      id: 0, // MockProductService asigna el id real al crear.
      code: _detectedCode!,
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text.replaceAll(',', '.')),
      stock: int.parse(_stockController.text),
      createdAt: DateTime.now(),
      category: 'Sin categoría',
    );

    await context.read<ProductCatalog>().addProduct(product);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto agregado')),
    );
    _nameController.clear();
    _priceController.clear();
    _stockController.clear();
    setState(() => _detectedCode = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Carga de producto', showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
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
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Nombre del producto'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Ingresá un nombre'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text('Precio', style: AppTextStyles.bodyBold),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(hintText: 'Precio (\$)'),
                  validator: (value) {
                    final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
                    if (parsed == null || parsed <= 0) return 'Ingresá un precio válido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Stock', style: AppTextStyles.bodyBold),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Cantidad inicial'),
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    if (parsed == null || parsed < 0) return 'Ingresá una cantidad válida';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                PrimaryButton(label: 'Subir', onPressed: _handleUpload),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
