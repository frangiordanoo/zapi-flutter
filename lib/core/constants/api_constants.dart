/// Configuracion de la API de Zapi.
class ApiConstants {
  ApiConstants._();

  /// URL base del backend. Se puede cambiar al compilar sin tocar codigo:
  /// `flutter run --dart-define=ZAPI_API_URL=http://10.0.2.2:3000`
  static const String baseUrl = String.fromEnvironment(
    'ZAPI_API_URL',
    defaultValue: 'https://zapi-rqos.onrender.com',
  );

  /// El backend corre en un plan gratuito que se "duerme" por inactividad:
  /// la primera peticion despues de un rato puede tardar bastante.
  static const Duration requestTimeout = Duration(seconds: 40);
}
