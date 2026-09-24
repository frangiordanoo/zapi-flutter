import 'package:flutter/material.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/core/widgets/secondary_button.dart';

/// Modal de confirmacion de borrado.
///
/// Devuelve `true` si el usuario confirmo, `false`/`null` si cancelo.
/// Quien llama a este dialogo es responsable de hacer el soft delete
/// real (ver AdminProductsScreen), este widget solo pregunta.
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
      title: const Text('¿Seguro que deseas borrar?'),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
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
            child: const Text('Borrar'),
          ),
        ),
      ],
    );
  }
}
