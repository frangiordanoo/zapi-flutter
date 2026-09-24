import 'package:flutter/material.dart';

/// Boton principal de la app (fondo violeta solido, ancho completo).
///
/// Usar para la accion principal de cada pantalla: "Escanear", "Pagar",
/// "Continuar", "Subir", "Aceptar", "Entrar", etc.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return ElevatedButton(onPressed: onPressed, child: Text(label));
    }
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }
}
