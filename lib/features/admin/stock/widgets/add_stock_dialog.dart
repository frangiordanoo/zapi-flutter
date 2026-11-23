import 'package:flutter/material.dart';
import 'package:zapi/core/widgets/secondary_button.dart';
import 'package:zapi/data/models/product.dart';

/// Pide cuantas unidades SUMAR al stock de [product]
/// (`PATCH /products/:code/stock`). Devuelve la cantidad (entero > 0) o
/// `null` si se cancela.
class AddStockDialog extends StatefulWidget {
  const AddStockDialog({super.key, required this.product});

  final Product product;

  @override
  State<AddStockDialog> createState() => _AddStockDialogState();
}

class _AddStockDialogState extends State<AddStockDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(int.parse(_controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Agregar stock a ${widget.product.name}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stock actual: ${widget.product.stock}'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(hintText: 'Unidades a sumar'),
              validator: (value) {
                final quantity = int.tryParse((value ?? '').trim());
                return (quantity == null || quantity <= 0)
                    ? 'Ingresá un entero mayor a 0'
                    : null;
              },
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
              child: ElevatedButton(onPressed: _submit, child: const Text('Agregar')),
            ),
          ],
        ),
      ],
    );
  }
}
