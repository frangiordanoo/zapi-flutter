import 'package:flutter/material.dart';
import 'package:zapi/core/widgets/primary_button.dart';
import 'package:zapi/core/widgets/secondary_button.dart';
import 'package:zapi/models/product.dart';

/// Modal para editar nombre y precio de un producto.
///
/// A proposito NO permite tocar codigo, stock ni categoria (ver
/// requerimiento de la pantalla Admin > Productos).
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

  void _handleSave() {
    final price = double.tryParse(_priceController.text.replaceAll(',', '.'));
    Navigator.of(context).pop(
      widget.product.copyWith(
        name: _nameController.text.trim(),
        price: price ?? widget.product.price,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar de producto'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nombre'),
          const SizedBox(height: 6),
          TextField(controller: _nameController),
          const SizedBox(height: 16),
          const Text('Precio'),
          const SizedBox(height: 6),
          TextField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
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
    );
  }
}
