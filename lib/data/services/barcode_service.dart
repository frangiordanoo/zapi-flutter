/// Contrato minimo para "algo que produce un codigo de barras".
///
/// Hoy no hay ninguna implementacion real todavia: la lectura de camara
/// se resuelve directamente dentro de `BarcodeScannerView`
/// (ver lib/core/widgets/barcode_scanner_view.dart) usando el paquete
/// `mobile_scanner`, que ya esta declarado en pubspec.yaml.
///
/// Esta interfaz queda preparada por si en el futuro se necesita separar
/// "la fuente del codigo" de "el widget que muestra la camara" (por
/// ejemplo para poder testear sin camara, o para soportar un lector de
/// codigo de barras fisico USB ademas de la camara).
abstract class BarcodeService {
  /// Devuelve el codigo detectado, o null si el usuario cancelo.
  Future<String?> scanBarcode();
}

/// Implementacion mock: devuelve siempre el mismo codigo de ejemplo.
/// Util para poder navegar y probar pantallas sin depender de la camara.
class MockBarcodeService implements BarcodeService {
  final String fixedCode;

  const MockBarcodeService({this.fixedCode = '7791234567890'});

  @override
  Future<String?> scanBarcode() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return fixedCode;
  }
}
