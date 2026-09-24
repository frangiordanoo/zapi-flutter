import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zapi/app/app.dart';
import 'package:zapi/core/constants/app_constants.dart';

void main() {
  testWidgets('La app arranca y muestra el Splash', (tester) async {
    await tester.pumpWidget(const ZapiApp());

    // El Splash muestra el logo de Zapi ("Z" + "API") apenas arranca,
    // antes de que dispare la navegacion automatica.
    expect(find.text('API'), findsOneWidget);
    expect(find.text('Z'), findsOneWidget);

    // El Splash programa un Timer para navegar solo despues de
    // AppConstants.splashTotalDuration (y ProductCatalog carga sus
    // datos mock con otro Timer corto). Avanzamos el reloj simulado
    // del test mas alla de ambos para que no quede ningun Timer
    // pendiente al terminar el test.
    await tester.pump(
      AppConstants.splashTotalDuration + const Duration(milliseconds: 100),
    );
  });
}
