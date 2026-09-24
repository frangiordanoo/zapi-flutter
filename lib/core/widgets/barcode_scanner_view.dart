import 'package:flutter/material.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/services/barcode_service.dart';

// ============================================================
// RESPONSABLE: Gonza
//
// TAREA:
// Reemplazar la camara simulada de este componente por la lectura real
// de codigos de barra usando el paquete `mobile_scanner` (ya esta
// agregado en pubspec.yaml, version ^5.2.3).
//
// OBJETIVO:
// Que `BarcodeScannerView` muestre la imagen de la camara en vivo
// dentro del rectangulo superior y, cuando detecte un codigo de barras
// valido, llame a `onCodeDetected(codigo)` con el numero detectado
// (String), tal como ya lo simula `MockBarcodeService`.
//
// COMPORTAMIENTO ESPERADO:
// - Al entrar a la pantalla, pedir permiso de camara (mobile_scanner ya
//   lo maneja internamente, pero hay que declarar el permiso en
//   Android/iOS: ver README.md / TEAM.md seccion "Scanner").
// - Mostrar el preview de camara dentro del rectangulo (reemplazar el
//   Container negro de placeholder).
// - Al detectar un codigo, llamar onCodeDetected UNA sola vez (evitar
//   que se dispare 30 veces por segundo mientras el codigo sigue en
//   cuadro: usar un flag o pausar el controller).
// - Mantener el mismo diseño visual (rectangulo redondeado, marco de
//   esquinas, texto de estado abajo) para no romper Scanner ni Add
//   Product, que ya usan este componente.
//
// NO DEBE HACER:
// - Llamadas al backend (la busqueda del producto por codigo la hacen
//   las pantallas que usan este widget, via ProductCatalog.findByCode).
//
// COMPONENTES EXISTENTES A REUTILIZAR:
// - AppColors / AppTextStyles para mantener el estilo.
// - Este mismo widget se usa en:
//   lib/features/client/scanner/client_scanner_screen.dart
//   lib/features/admin/add_product/admin_add_product_screen.dart
//
// PROMPT PARA IA:
//
// "Estoy trabajando en una app Flutter (Material 3) llamada Zapi.
// Tengo un widget en lib/core/widgets/barcode_scanner_view.dart llamado
// BarcodeScannerView que hoy muestra un placeholder (un Container negro
// con un marco de esquinas dibujado con Stack/Positioned) en lugar de
// la camara real, y expone un callback `onCodeDetected(String code)` y
// un boton de debug 'Simular escaneo'. Quiero que reemplaces el
// contenido interno de ese widget para usar el paquete mobile_scanner
// (^5.2.3, ya esta en pubspec.yaml) y mostrar la camara en vivo dentro
// del mismo rectangulo redondeado que ya existe, detectando codigos de
// barra reales y llamando a onCodeDetected con el valor detectado (una
// sola vez por codigo, evitando llamados repetidos mientras el codigo
// sigue en cuadro). Mantene la firma publica del widget
// (BarcodeScannerView({onCodeDetected, statusText})) para no romper las
// pantallas que ya lo usan (client_scanner_screen.dart y
// admin_add_product_screen.dart). Decime tambien que permisos hay que
// agregar en AndroidManifest.xml y en Info.plist para que la camara
// funcione, y si hace falta manejar el ciclo de vida (pausar la camara
// al salir de la pantalla)."
// ============================================================

/// Camara para escanear codigos de barra.
///
/// HOY: muestra un placeholder (rectangulo negro con marco de esquinas)
/// y un boton de debug que simula un escaneo exitoso usando
/// [MockBarcodeService], para poder navegar y probar toda la app sin
/// depender de la camara real. Ver el bloque de comentarios de arriba
/// para la integracion real con `mobile_scanner`.
class BarcodeScannerView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white24,
                    size: 48,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: _ScanFrame(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          statusText ?? 'Escaneá el producto',
          style: AppTextStyles.bodyBold,
        ),
        const SizedBox(height: 4),
        Text(
          'Centra el código de barras con la guía.',
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        // TODO(Gonza): borrar este boton de debug cuando la camara real
        // este integrada, o dejarlo detras de un flag de desarrollo.
        OutlinedButton.icon(
          onPressed: () async {
            final code = await const MockBarcodeService().scanBarcode();
            if (code != null) onCodeDetected(code);
          },
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Simular escaneo (debug)'),
        ),
      ],
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
