import 'package:flutter/material.dart';

/// Paleta de colores centralizada de Zapi.
///
/// Regla del proyecto: NUNCA escribir un `Color(0xFF...)` suelto dentro
/// de una pantalla o widget. Si falta un color, se agrega aca (con un
/// nombre que describa su USO, no el tono) y se usa desde todos lados
/// como `AppColors.primary`, etc. Esto es lo que nos permite despues
/// cambiar el look de toda la app tocando un solo archivo.
class AppColors {
  AppColors._();

  // Marca
  static const Color primary = Color(0xFF6C4EE0);
  static const Color primaryDark = Color(0xFF5433C4);
  static const Color primaryLight = Color(0xFFEDE7FB);

  // Estados / acciones
  static const Color success = Color(0xFF20B876);
  static const Color danger = Color(0xFFE5484D);
  static const Color warning = Color(0xFFF5A524);

  // Superficies
  static const Color background = Color(0xFFF7F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE6E4F0);

  // Texto
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF8A8A9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
}
