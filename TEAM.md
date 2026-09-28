# Equipo y forma de trabajo - Zapi

> **Nota:** por tiempo de entrega, la funcionalidad completa (incluyendo
> el escaneo real con cámara, validaciones de formulario y demás
> pendientes) se terminó de implementar sin dividir por integrante. Esta
> tabla queda como referencia de cómo se pensó originalmente repartir el
> trabajo y sigue siendo útil para entender qué pantalla explica cada
> parte de la arquitectura.

## Integrantes y responsabilidades

### Administrador

| Integrante | Responsable de |
|---|---|
| **Facundo Palavecino** | Estructura global (routing, tema, componentes globales) y pantalla **Estadísticas / Dashboard** |
| **Facundo Fornes** | **Login**, navegación del admin, pantalla **Productos** (con modal editar y modal eliminar) |
| **Renzo** | **Stock**, **Stock Review**, y una tarea chica del lado cliente (estado/carrito compartido) |
| **Gonza** | **Add Product**, integración visual del **Scanner** (BarcodeScannerView) |

### Cliente

| Integrante | Responsable de |
|---|---|
| **Misa** | **Splash / animación de Zapi**, **Client Home / Carrito** |
| **Fran** | **Product List**, selección de productos, flujo hacia el carrito |
| **Renzo** | Ayuda con integración visual/estado compartido del carrito y scanner (además de sus tareas de admin) |

Cada pantalla tiene, arriba del todo del archivo, un bloque de comentario
`RESPONSABLE / TAREA / OBJETIVO / ...` con el detalle exacto de qué hacer
y un prompt listo para pegar en otra IA. Buscá tu nombre en los
archivos de `lib/features/` para encontrar tu tarea.

Archivos con tu tarea, por integrante:

- **Facundo Palavecino**: `lib/features/admin/dashboard/admin_dashboard_screen.dart`, `lib/features/admin/admin_shell.dart` (estructura, no una pantalla nueva)
- **Facundo Fornes**: `lib/features/admin/login/admin_login_screen.dart`, `lib/features/admin/products/admin_products_screen.dart`
- **Renzo**: `lib/features/admin/stock/admin_stock_screen.dart`, `lib/features/admin/stock_review/admin_stock_review_screen.dart`
- **Gonza**: `lib/features/admin/add_product/admin_add_product_screen.dart`, `lib/core/widgets/barcode_scanner_view.dart`
- **Misa**: `lib/features/splash/splash_screen.dart`, `lib/features/client/cart/client_cart_screen.dart`
- **Fran**: `lib/features/client/product_list/client_product_list_screen.dart`
- **Renzo (cliente)**: `lib/features/client/scanner/client_scanner_screen.dart` (junto con Gonza)

## Estructura del proyecto

```
lib/
├── main.dart                 # Punto de entrada
├── app/
│   ├── app.dart               # Widget raiz (Provider + MaterialApp)
│   ├── router/                # Routing centralizado
│   └── theme/                 # Colores, tipografia, ThemeData
├── core/
│   ├── constants/              # Constantes generales
│   ├── utils/                  # Formatters, etc.
│   └── widgets/                 # Componentes reutilizables (AppHeader, botones, etc.)
├── models/                    # Product, CartItem
├── mock/                      # Datos de prueba centralizados
├── services/                  # Interfaces + implementaciones mock (futuro backend)
├── state/                     # CartController, ProductCatalog (estado compartido)
└── features/
    ├── splash/
    ├── client/                 # cart, scanner, product_list
    └── admin/                  # login, dashboard, products, stock, add_product, stock_review
```

## Cómo ejecutar el proyecto

```bash
flutter pub get
flutter run
```

Requiere tener el SDK de Flutter instalado (canal stable) y un
emulador/dispositivo conectado, o usar `flutter run -d chrome` para
probar rápido en el navegador (ojo: el scanner de cámara no va a andar
igual en web).

## Cómo agregar una pantalla nueva

1. Crear el archivo dentro de `lib/features/<cliente|admin>/<seccion>/`.
2. Agregar el nombre de ruta en `lib/app/router/route_names.dart`.
3. Agregar el `case` correspondiente en `lib/app/router/app_router.dart`.
4. Navegar con `Navigator.pushNamed(context, RouteNames.tuRuta)` (nunca
   con un String suelto).

## Dónde está todo

- **Rutas**: `lib/app/router/` (nombres en `route_names.dart`, mapeo en `app_router.dart`).
- **Mocks**: `lib/mock/` (`mock_products.dart`, `mock_stats.dart`). Si necesitás más datos de prueba, agregalos ahí.
- **Modelos**: `lib/models/` (`Product`, `CartItem`).
- **Componentes reutilizables**: `lib/core/widgets/` (headers, botones, items de lista, etc.) y `lib/features/admin/widgets/` (navbar del admin).
- **Estado compartido**: `lib/state/` (`CartController` para el carrito, `ProductCatalog` para el catálogo de productos). Ambos son `ChangeNotifier` simples, expuestos con `provider` desde `lib/app/app.dart`.
- **Servicios / futuro backend**: `lib/services/` (`ProductService` es la interfaz, `MockProductService` la implementación actual).

## Cómo trabajar en paralelo sin pisarnos

- Cada uno trabaja principalmente dentro de su/s pantalla/s en `lib/features/...`. Eso minimiza conflictos de Git porque son archivos distintos.
- **Archivos que NO deberían tocarse sin avisar al resto** (son compartidos por todos):
  - `lib/app/router/route_names.dart` y `app_router.dart`
  - `lib/app/theme/*`
  - `lib/state/cart_controller.dart` y `lib/state/product_catalog.dart`
  - `lib/models/*`
  - `lib/core/widgets/*` (si necesitás cambiar un componente reutilizable para tu pantalla, avisá en el grupo antes, porque afecta a otras pantallas)
  - `pubspec.yaml`
- Si necesitás agregar un campo al modelo `Product` o cambiar la firma de `CartController`/`ProductCatalog`, coordinalo con el equipo antes (probablemente varias pantallas dependen de eso).

## Scanner (permisos de cámara)

Cuando Gonza integre `mobile_scanner` de verdad en `BarcodeScannerView`
(hoy es un placeholder), va a hacer falta declarar el permiso de cámara:

- **Android**: agregar en `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <uses-permission android:name="android.permission.CAMERA" />
  ```
- **iOS**: agregar en `ios/Runner/Info.plist`:
  ```xml
  <key>NSCameraUsageDescription</key>
  <string>Zapi necesita la cámara para escanear códigos de barra</string>
  ```

Estos permisos ya vienen agregados en este scaffold para que no haya que
acordarse de configurarlos al integrar la cámara real.

## Git

Trabajar con una rama por feature, con este formato:

```
feature/nombre-de-la-feature
```

Ejemplos:

```
feature/client-cart
feature/client-scanner
feature/client-product-list
feature/admin-login
feature/admin-products
feature/admin-stock
feature/admin-stock-review
feature/admin-add-product
feature/admin-dashboard
```

Al terminar tu tarea, abrí un Pull Request contra `main` para que el
resto pueda revisar antes de mergear.
