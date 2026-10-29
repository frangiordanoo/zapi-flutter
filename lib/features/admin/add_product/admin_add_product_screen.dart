import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/core/widgets/barcode_scanner_view.dart';
import 'package:zapi/core/widgets/primary_button.dart';
import 'package:zapi/data/models/product.dart';
import 'package:zapi/state/product_catalog.dart';

/// Pantalla de carga de un producto nuevo por parte del administrador.
///
/// El codigo de barras se completa con [BarcodeScannerView] (camara real
/// con `mobile_scanner`, con boton de respaldo para simular el escaneo).
/// Al subir, el producto se crea en la API (`POST /products`) a traves de
/// [ProductCatalog], que despues recarga el listado completo.
class AdminAddProductScreen extends StatefulWidget {
  const AdminAddProductScreen({super.key});

  @override
  State<AdminAddProductScreen> createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _detectedCode;
  bool _submitting = false;
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleUpload() async {
    if (_submitting) return;

    if (_detectedCode == null) {
      _showMessage('Escaneá o simulá un código de barras primero');
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final catalog = context.read<ProductCatalog>();
    if (catalog.products.any((p) => p.code == _detectedCode)) {
      _showMessage('Ya existe un producto con el código $_detectedCode');
      return;
    }

    final product = Product(
      id: 0, // El id real lo asigna la API.
      code: _detectedCode!,
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text.trim().replaceAll(',', '.')),
      stock: int.parse(_stockController.text.trim()),
      category: _categoryController.text.trim(),
    );

    setState(() => _submitting = true);
    try {
      await catalog.addProduct(product);
      if (!mounted) return;
      _showMessage('Producto agregado');
      _nameController.clear();
      _priceController.clear();
      _stockController.clear();
      _categoryController.clear();
      setState(() => _detectedCode = null);
    } on AppException catch (e) {
      if (!mounted) return;
      _showMessage('No se pudo crear el producto: ${e.message}');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingCategories = (context
            .watch<ProductCatalog>()
            .products
            .map((p) => p.category)
            .where((c) => c != Product.defaultCategory)
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())));

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
                  enabled: !_submitting,
                  decoration: const InputDecoration(hintText: 'Nombre del producto'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Ingresá un nombre'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text('Categoría', style: AppTextStyles.bodyBold),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _categoryController,
                  enabled: !_submitting,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Ej: Bebidas'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Ingresá una categoría'
                      : null,
                ),
                if (existingCategories.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final category in existingCategories)
                        ActionChip(
                          label: Text(category),
                          onPressed: _submitting
                              ? null
                              : () => _categoryController.text = category,
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                const Text('Precio', style: AppTextStyles.bodyBold),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _priceController,
                  enabled: !_submitting,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(hintText: 'Precio (\$)'),
                  validator: (value) {
                    final parsed =
                        double.tryParse((value ?? '').trim().replaceAll(',', '.'));
                    if (parsed == null || parsed < 0 || !parsed.isFinite) {
                      return 'Ingresá un precio válido (no negativo)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Stock', style: AppTextStyles.bodyBold),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _stockController,
                  enabled: !_submitting,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Cantidad inicial'),
                  validator: (value) {
                    final parsed = int.tryParse((value ?? '').trim());
                    if (parsed == null || parsed < 0) {
                      return 'Ingresá una cantidad entera (0 o más)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (_submitting)
                  const Center(child: CircularProgressIndicator())
                else
                  PrimaryButton(label: 'Subir', onPressed: _handleUpload),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
