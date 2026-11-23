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

  /// Codigo escaneado que YA esta cargado: no se deja crear de nuevo.
  String? _existingCode;
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

  /// Al escanear se consulta al backend si el producto ya existe (como el
  /// frontend web): si existe no se acepta el codigo. `GET /products/:code`
  /// solo ve productos activos, asi que tambien se miran los ocultos.
  Future<void> _handleCodeDetected(String code) async {
    final catalog = context.read<ProductCatalog>();
    Product? existing;
    try {
      existing = await catalog.findByCode(code);
    } on AppException catch (e) {
      if (mounted) _showMessage('No se pudo verificar el código: ${e.message}');
      return;
    }
    if (!mounted) return;

    final alreadyStored =
        existing != null || catalog.adminProducts.any((p) => p.code == code);
    setState(() {
      _existingCode = alreadyStored ? code : null;
      _detectedCode = alreadyStored ? null : code;
    });
  }

  Future<void> _handleUpload() async {
    if (_submitting) return;

    if (_detectedCode == null) {
      _showMessage('Escaneá o simulá un código de barras primero');
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final catalog = context.read<ProductCatalog>();
    if (catalog.products.any((p) => p.code == _detectedCode) ||
        catalog.adminProducts.any((p) => p.code == _detectedCode)) {
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
      setState(() {
        _detectedCode = null;
        _existingCode = null;
      });
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
            .stockProducts
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
                  // Para dar de alta hace falta un codigo que todavia no exista.
                  simulatedCode: () =>
                      '779${DateTime.now().millisecondsSinceEpoch % 10000000000}',
                  onCodeDetected: _handleCodeDetected,
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _existingCode != null
                        ? AppColors.danger
                        : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _existingCode != null
                        ? 'Este producto ya está almacenado'
                        : _detectedCode == null
                            ? 'No se detectó ningún código'
                            : 'Código detectado:\n$_detectedCode',
                    style: AppTextStyles.bodyBold.copyWith(
                      color: _existingCode != null ? Colors.white : null,
                    ),
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
                    // El backend exige un precio mayor que 0.
                    if (parsed == null || parsed <= 0 || !parsed.isFinite) {
                      return 'El precio debe ser mayor a 0';
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
