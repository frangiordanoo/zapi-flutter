import 'package:flutter/material.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/core/widgets/secondary_button.dart';

/// Modal de confirmacion para ocultar un producto.
///
/// Devuelve `true` si el usuario confirmo, `false`/`null` si cancelo.
/// Quien llama a este dialogo es responsable de ocultar el producto de
/// verdad (ver AdminProductsScreen), este widget solo pregunta. Ocultar es
/// un borrado logico: el producto se puede recuperar despues.
///
/// Uso:
/// ```dart
/// final confirmed = await showDialog<bool>(
///   context: context,
///   builder: (_) => const DeleteProductDialog(),
/// );
/// ```
class DeleteProductDialog extends StatelessWidget {
  const DeleteProductDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('¿Seguro que deseas ocultar este producto?'),
      content: const Text('Dejará de verse para los clientes. Podés recuperarlo más tarde.'),
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
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Ocultar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
