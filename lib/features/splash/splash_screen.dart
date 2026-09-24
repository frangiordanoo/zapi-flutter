import 'package:flutter/material.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/core/constants/app_constants.dart';
import 'package:zapi/core/widgets/zapi_logo.dart';

// ============================================================
// RESPONSABLE: Misa
//
// TAREA:
// Crear la animacion de entrada de Zapi utilizando los SVG que
// proporcione el equipo de diseño (todavia no estan agregados, ver
// assets/svg/PLACEHOLDER.md).
//
// OBJETIVO:
// Reemplazar/mejorar la animacion simple que ya esta implementada
// (fade + scale con AnimatedOpacity/AnimatedScale sobre `ZapiLogo`) por
// una animacion mas pulida, corta y moderna, idealmente usando los
// SVG reales del logo en vez del placeholder de `ZapiLogo`
// (lib/core/widgets/zapi_logo.dart).
//
// INVESTIGAR:
// - Flutter animations (implicit vs explicit)
// - AnimatedOpacity / AnimatedScale / AnimatedSlide (lo que ya se usa)
// - AnimationController + Tween (para mas control, ej. animaciones
//   encadenadas o con curvas custom)
// - flutter_svg (SvgPicture.asset) para renderizar el logo real
//
// COMPORTAMIENTO ESPERADO:
// - Al abrir la app se ve el splash con el logo animando su entrada.
// - Despues de AppConstants.splashTotalDuration navega sola a
//   Client Cart (comportamiento normal, un kiosco arranca en modo
//   cliente).
// - Se mantiene el acceso oculto a Admin Login (5 taps sobre el logo)
//   que ya esta implementado mas abajo, para no romper el flujo del
//   equipo de administracion. Se puede cambiar el mecanismo si el
//   equipo decide otro (por ejemplo un boton discreto), pero
//   documentando el cambio aca.
//
// NO DEBE HACER:
// - Llamadas al backend, autenticacion, ni logica de negocio.
//
// DEBE UTILIZAR:
// - ZapiLogo (lib/core/widgets/zapi_logo.dart)
// - AppColors / AppConstants
//
// PROMPT PARA IA:
//
// "Estoy trabajando en una app Flutter (Material 3) llamada Zapi.
// Tengo una pantalla en lib/features/splash/splash_screen.dart
// (SplashScreen, StatefulWidget) que hoy hace una animacion simple de
// entrada (fade + scale) sobre un widget ZapiLogo
// (lib/core/widgets/zapi_logo.dart) con fondo violeta solido
// (AppColors.primary), y despues de
// AppConstants.splashTotalDuration navega con
// Navigator.pushReplacementNamed(context, RouteNames.clientCart).
// Quiero que mejores la animacion de entrada para que se vea mas
// moderna y prolija (podes usar AnimationController + Tween si hace
// falta mas control), manteniendo la duracion corta (no mas de ~2
// segundos en total) y sin romper la navegacion automatica al final ni
// el gesto oculto de 5 taps que lleva a Admin Login. Si te paso los
// SVG del logo real (los voy a poner en assets/svg/), reemplaza
// ZapiLogo por SvgPicture.asset('assets/svg/zapi_logo.svg') dentro de
// ese mismo widget para no tener que tocar esta pantalla."
// ============================================================

/// Pantalla de entrada de la app (animacion + logo de Zapi).
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
  /// seguidas. Es un mecanismo temporal para no exponer un boton de
  /// "Admin" en la pantalla principal del kiosco; el equipo puede
  /// cambiarlo por otro gesto/boton si lo prefiere (ver TAREA arriba).
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
            child: AnimatedScale(
              scale: _visible ? 1 : 0.85,
              duration: AppConstants.splashAnimationDuration,
              curve: Curves.easeOutBack,
              child: const ZapiLogo(size: 88, light: true),
            ),
          ),
        ),
      ),
    );
  }
}
