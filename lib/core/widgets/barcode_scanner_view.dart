import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/services/barcode_service.dart';

/// Camara para escanear codigos de barra.
///
/// Usa el paquete `mobile_scanner` para mostrar la camara en vivo y
/// detectar codigos de barra reales (Android, iOS, Web, desktop). Ademas
/// mantiene un boton "Simular escaneo" como respaldo: sirve para
/// demostrar el flujo completo de la app sin depender de tener una
/// camara disponible o un producto fisico con el codigo de barras a
/// mano (por ejemplo al mostrar la app en una compu sin camara, o en un
/// despliegue web para que alguien la pruebe rapido).
///
/// Permisos necesarios (ya configurados en este proyecto):
/// - Android: `android.permission.CAMERA` en AndroidManifest.xml.
/// - iOS: `NSCameraUsageDescription` en Info.plist.
/// - Web: el navegador pide permiso de camara automaticamente (requiere
///   HTTPS o localhost).
class BarcodeScannerView extends StatefulWidget {
  const BarcodeScannerView({
    super.key,
    required this.onCodeDetected,
    this.statusText,
  });

  /// Se llama con el codigo detectado (ej: "7791234567890").
  final ValueChanged<String> onCodeDetected;

  /// Texto que se muestra debajo de la camara (ej: "Escaneá el producto").
  final String? statusText;

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  // Evita disparar onCodeDetected varias veces mientras el mismo codigo
  // sigue en cuadro (la camara sigue mandando frames continuamente).
  bool _handled = false;

  void _handleDetect(BarcodeCapture capture) {
    if (_handled) return;
    final value = capture.barcodes.isEmpty
        ? null
        : capture.barcodes.first.rawValue;
    if (value == null) return;
    _handled = true;
    widget.onCodeDetected(value);
  }

  Future<void> _handleSimulate() async {
    final code = await const MockBarcodeService().scanBarcode();
    if (code != null) widget.onCodeDetected(code);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ColoredBox(
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    controller: _controller,
                    onDetect: _handleDetect,
                    errorBuilder: (context, error, child) => const _CameraFallback(),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(28),
                    child: _ScanFrame(),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.statusText ?? 'Escaneá el producto',
          style: AppTextStyles.bodyBold,
        ),
        const SizedBox(height: 4),
        const Text(
          'Centra el código de barras con la guía.',
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        // Respaldo para poder probar el flujo completo sin camara o sin
        // tener a mano un producto con el codigo de barras impreso.
        OutlinedButton.icon(
          onPressed: _handleSimulate,
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Simular escaneo'),
        ),
      ],
    );
  }
}

/// Se muestra si la camara no esta disponible o el permiso fue denegado.
class _CameraFallback extends StatelessWidget {
  const _CameraFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_off_outlined, color: Colors.white54, size: 40),
            SizedBox(height: 8),
            Text(
              'No se pudo acceder a la cámara.\nUsá "Simular escaneo" para continuar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// Marco de esquinas estilo "mira de escaneo", dibujado con widgets
/// simples (sin assets) para dar la sensacion de guia de camara.
class _ScanFrame extends StatelessWidget {
  const _ScanFrame();

  @override
  Widget build(BuildContext context) {
    const side = BorderSide(color: AppColors.primaryLight, width: 3);
    const length = 28.0;

    Widget corner({required Alignment alignment, required BoxBorder border}) {
      return Align(
        alignment: alignment,
        child: SizedBox(
          width: length,
          height: length,
          child: DecoratedBox(decoration: BoxDecoration(border: border)),
        ),
      );
    }

    return Stack(
      children: [
        corner(
          alignment: Alignment.topLeft,
          border: const Border(top: side, left: side),
        ),
        corner(
          alignment: Alignment.topRight,
          border: const Border(top: side, right: side),
        ),
        corner(
          alignment: Alignment.bottomLeft,
          border: const Border(bottom: side, left: side),
        ),
        corner(
          alignment: Alignment.bottomRight,
          border: const Border(bottom: side, right: side),
        ),
      ],
    );
  }
}
