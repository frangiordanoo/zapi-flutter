# Zapi

Aplicación móvil de autoservicio para un kiosco: el cliente escanea o
selecciona productos, arma su carrito y (en el futuro) paga desde el
celular/kiosco. También incluye un panel de administración para
gestionar productos, stock y ver estadísticas de ventas.

## Objetivo de este proyecto

Este repo es el **punto de partida arquitectónico** para que el equipo
(7 personas, sin experiencia previa significativa en Flutter) pueda
trabajar en paralelo sobre una base clara. **No** implementa todavía
backend, pagos ni autenticación real: todo eso está simulado con datos
mock, dejando la estructura lista para conectarlo después.

## Tecnologías

- Flutter / Dart
- Material 3
- [`provider`](https://pub.dev/packages/provider) para estado compartido simple (carrito, catálogo de productos)
- [`flutter_svg`](https://pub.dev/packages/flutter_svg) para los íconos/logo de Zapi
- [`mobile_scanner`](https://pub.dev/packages/mobile_scanner) para lectura de códigos de barra
- [`fl_chart`](https://pub.dev/packages/fl_chart) para los gráficos del dashboard
- [`intl`](https://pub.dev/packages/intl) para formateo de precios/fechas

## Arquitectura

Arquitectura por *features*, simple a propósito (sin capas
innecesarias para un equipo junior):

```
lib/
├── app/        -> arranque de la app: routing, tema, Provider
├── core/       -> constantes, utils y widgets reutilizables entre features
├── models/     -> Product, CartItem
├── mock/       -> datos de prueba centralizados
├── services/   -> interfaces (ProductService) + implementación mock
├── state/      -> estado compartido (CartController, ProductCatalog)
└── features/
    ├── splash/
    ├── client/   -> cart, scanner, product_list
    └── admin/    -> login, dashboard, products, stock, add_product, stock_review
```

Ver [TEAM.md](TEAM.md) para el detalle de estructura, responsables y
cómo trabajar en paralelo.

## Cómo ejecutar

```bash
flutter pub get
flutter run
```

## Integrantes

- Facundo Palavecino
- Facundo Fornes
- Renzo
- Gonza
- Misa
- Fran

(Ver asignación de tareas en [TEAM.md](TEAM.md))

## Funcionalidades

### Cliente (kiosco)

- Splash con animación de entrada de Zapi.
- Carrito de compras (pantalla principal), con cantidad, eliminar y total.
- Escaneo de código de barras para agregar productos al carrito.
- Lista de productos para agregar sin usar la cámara.

### Administrador

- Login (sin autenticación real todavía).
- Dashboard de estadísticas (ventas, producto más vendido, gráficos).
- Gestión de productos: buscar, editar (nombre/precio), borrar (soft delete).
- Gestión de stock: ver stock actual y hacer una revisión física.
- Alta de productos nuevos, con escaneo de código de barras.

## Qué está implementado

- Todas las pantallas listadas arriba, navegables de punta a punta.
- Routing centralizado (`lib/app/router/`).
- Componentes reutilizables (header, botones, items de lista, buscador, selector de cantidad, scanner placeholder).
- Modelos y datos mock realistas.
- Capa de servicios preparada para reemplazar mocks por un backend real sin tocar las pantallas.

## Qué está mockeado

- **Productos**: `lib/mock/mock_products.dart`, servidos vía `MockProductService` (simula latencia de red).
- **Estadísticas**: `lib/mock/mock_stats.dart`.
- **Autenticación**: el login acepta cualquier valor, no valida contra nada.
- **Escaneo de código de barras**: `BarcodeScannerView` simula la detección con un botón de debug (`MockBarcodeService`); la cámara real está pendiente de integrar (ver comentario `RESPONSABLE: Gonza` en ese archivo).
- **Pago**: el botón "Pagar" en el Scanner es solo visual, no llama a ningún servicio.

## Qué queda pendiente de backend

- Reemplazar `MockProductService` por un `ApiProductService` real que implemente `ProductService` (`lib/services/product_service.dart`).
- Agregar el campo `isDeleted` (soft delete) al modelo `Product` de Prisma (ver comentario en `lib/models/product.dart`).
- Autenticación real de administrador.
- Integración de pago (Mercado Pago u otro medio).
- Persistencia real de stock (hoy se actualiza solo en memoria).
- Lectura real de código de barras por cámara (`mobile_scanner`, ver `lib/core/widgets/barcode_scanner_view.dart`).
- SVG oficiales de Zapi (`assets/svg/`, ver `assets/svg/PLACEHOLDER.md`).
