# SVG de Zapi

Colocar aca los archivos SVG oficiales de la app. Nombres sugeridos
(usados como referencia en los comentarios del codigo, podes cambiarlos
siempre que actualices los mismos comentarios):

- `zapi_logo.svg` -> logo completo (usado en el Splash).
- `zapi_isotipo.svg` -> version reducida del logo (opcional, para AppBar/header).
- `empty_cart.svg` -> ilustracion de carrito vacio (opcional, hoy se usa un icono de Material como placeholder).

Una vez agregado un archivo ya queda disponible automaticamente porque
`pubspec.yaml` declara toda la carpeta `assets/svg/` como asset. No hace
falta tocar el pubspec.

Para usarlo en codigo:

```dart
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset('assets/svg/zapi_logo.svg', width: 120);
```

Ver `lib/core/widgets/zapi_logo.dart` para el lugar exacto donde
reemplazar el placeholder actual (un Container + Text) por el SVG real.
