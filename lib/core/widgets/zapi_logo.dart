import 'package:flutter/material.dart';
import 'package:zapi/app/theme/app_colors.dart';

/// Logo de Zapi ("Z" en un cuadrado + "API").
///
/// Hoy esta construido con widgets normales (Container + Text) para que
/// la app funcione sin depender de ningun archivo externo. El paquete
/// `flutter_svg` ya esta agregado en pubspec.yaml y la carpeta
/// `assets/svg/` ya esta declarada como asset, asi que cuando el equipo
/// tenga el logo definitivo en SVG, alcanza con reemplazar el `_ZBadge`
/// de mas abajo por:
///
/// ```dart
/// SvgPicture.asset('assets/svg/zapi_logo.svg', height: size)
/// ```
///
/// Ver responsable de esto en lib/features/splash/splash_screen.dart.
class ZapiLogo extends StatelessWidget {
  const ZapiLogo({super.key, this.size = 72, this.light = false});

  /// Alto aproximado del logo.
  final double size;

  /// Si es true, usa colores para fondos oscuros (texto blanco).
  final bool light;

  @override
  Widget build(BuildContext context) {
    final textColor = light ? Colors.white : AppColors.textPrimary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ZBadge(size: size),
        SizedBox(width: size * 0.18),
        Text(
          'API',
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _ZBadge extends StatelessWidget {
  const _ZBadge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      alignment: Alignment.center,
      child: Text(
        'Z',
        style: TextStyle(
          fontSize: size * 0.55,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}
