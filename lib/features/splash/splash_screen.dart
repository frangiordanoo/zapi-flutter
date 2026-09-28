import 'package:flutter/material.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/core/constants/app_constants.dart';
import 'package:zapi/core/widgets/zapi_logo.dart';

/// Pantalla de entrada de la app: logo de Zapi con una animacion corta
/// de fade + scale + slide hacia arriba.
///
/// Al terminar [AppConstants.splashTotalDuration] navega sola al
/// carrito del cliente (comportamiento normal de un kiosco). Tocar el
/// logo 5 veces seguidas es el acceso oculto al login de administrador,
/// para no exponer un boton de "Admin" visible en la pantalla principal.
///
/// El logo usa el placeholder de [ZapiLogo] (Container + Text); cuando
/// el equipo tenga el SVG oficial de Zapi (ver assets/svg/PLACEHOLDER.md)
/// alcanza con reemplazar el contenido de ese widget por
/// `SvgPicture.asset('assets/svg/zapi_logo.svg')`, sin tocar esta pantalla.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _visible = false;
  int _logoTaps = 0;

  @override
  void initState() {
    super.initState();
    // Dispara la animacion de entrada en el siguiente frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _visible = true);
    });

    Future.delayed(AppConstants.splashTotalDuration, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(RouteNames.clientCart);
    });
  }

  /// Acceso oculto al login de administrador: tocar el logo 5 veces
  /// seguidas, para no exponer un boton de "Admin" en la pantalla
  /// principal del kiosco.
  void _handleLogoTap() {
    _logoTaps++;
    if (_logoTaps >= 5) {
      _logoTaps = 0;
      Navigator.of(context).pushReplacementNamed(RouteNames.adminLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: GestureDetector(
          onTap: _handleLogoTap,
          child: AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: AppConstants.splashAnimationDuration,
            curve: Curves.easeOut,
            child: AnimatedSlide(
              offset: _visible ? Offset.zero : const Offset(0, 0.08),
              duration: AppConstants.splashAnimationDuration,
              curve: Curves.easeOutCubic,
              child: AnimatedScale(
                scale: _visible ? 1 : 0.85,
                duration: AppConstants.splashAnimationDuration,
                curve: Curves.easeOutBack,
                child: const ZapiLogo(size: 88, light: true),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
