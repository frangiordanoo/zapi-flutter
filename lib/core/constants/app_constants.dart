/// Constantes generales de la app que no tienen un lugar mas especifico.
class AppConstants {
  AppConstants._();

  static const String appName = 'Zapi';

  /// Duracion de la animacion de entrada del Splash.
  static const Duration splashAnimationDuration = Duration(milliseconds: 900);

  /// Cuanto tiempo se queda el Splash en pantalla antes de navegar
  /// automaticamente (incluye la animacion).
  static const Duration splashTotalDuration = Duration(milliseconds: 2200);
}
