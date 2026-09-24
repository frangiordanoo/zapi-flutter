import 'package:flutter/material.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';

/// Header reutilizable para todas las pantallas.
///
/// Se usa como `appBar` de un `Scaffold`:
///
/// ```dart
/// Scaffold(
///   appBar: const AppHeader(title: 'Mi carrito'),
///   body: ...,
/// )
/// ```
///
/// Por defecto tiene fondo violeta y texto blanco (como en "Mi carrito" /
/// "Stocks"). Para el estilo claro con texto violeta (como en
/// "Productos" / "Estadisticas") pasar `light: true`.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.light = false,
    this.showBackButton = false,
    this.trailing,
  });

  final String title;

  /// true = fondo blanco / texto violeta. false (default) = fondo violeta / texto blanco.
  final bool light;

  final bool showBackButton;

  /// Widget opcional a la derecha (ej: un icono de accion).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = light ? AppColors.background : AppColors.primary;
    final textColor = light ? AppColors.primary : AppColors.textOnPrimary;

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      title: Text(
        title,
        style: AppTextStyles.headerTitle.copyWith(color: textColor),
      ),
      actions: trailing == null ? null : [trailing!, const SizedBox(width: 8)],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
