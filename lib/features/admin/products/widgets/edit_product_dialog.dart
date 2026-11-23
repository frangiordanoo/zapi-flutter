import 'package:flutter/material.dart';
import 'package:zapi/core/widgets/primary_button.dart';
import 'package:zapi/core/widgets/secondary_button.dart';
import 'package:zapi/data/models/product.dart';

/// Modal para editar nombre y precio de un producto.
///
/// A proposito NO permite tocar codigo, stock ni categoria: el backend
/// (`PUT /products/:code`) solo acepta nombre y precio.
///
/// Validaciones (las mismas que el frontend web y el backend): nombre de 2 a
/// 100 caracteres y precio mayor que 0. Si algo es invalido se muestra el
/// error y el dialogo NO se cierra.
///
/// Uso:
/// ```dart
/// final updated = await showDialog<Product>(
///   context: context,
///   builder: (_) => EditProductDialog(product: product),
/// );
/// if (updated != null) { ... }
/// ```
class EditProductDialog extends StatefulWidget {
  const EditProductDialog({super.key, required this.product});

  final Product product;

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController =
      TextEditingController(text: widget.product.name);
  late final TextEditingController _priceController =
      TextEditingController(text: widget.product.price.toStringAsFixed(2));

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  static double? _parsePrice(String? text) =>
      double.tryParse((text ?? '').trim().replaceAll(',', '.'));

  String? _validateName(String? value) {
    final name = (value ?? '').trim();
    if (name.length < 2) return 'El nombre debe tener al menos 2 caracteres';
    if (name.length > 100) return 'El nombre no puede superar los 100 caracteres';
    return null;
  }

  String? _validatePrice(String? value) {
    final price = _parsePrice(value);
    if (price == null || !price.isFinite) return 'El precio debe ser un número';
    if (price <= 0) return 'El precio debe ser mayor que 0';
    return null;
  }

  void _handleSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      widget.product.copyWith(
        name: _nameController.text.trim(),
        price: _parsePrice(_priceController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar producto'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nombre'),
            const SizedBox(height: 6),
            TextFormField(controller: _nameController, validator: _validateName),
            const SizedBox(height: 16),
            const Text('Precio'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePrice,
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      // OJO: AlertDialog envuelve `actions` en un OverflowBar, que no
      // acepta widgets Expanded directamente (rompe con un
      // "Incorrect use of ParentDataWidget"). Por eso los botones van
      // dentro de un Row propio, pasado como UN solo elemento de
      // `actions`.
      actions: [
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'Cancelar',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(label: 'Editar', onPressed: _handleSave),
            ),
          ],
        ),
      ],
    );
  }
}
