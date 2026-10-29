# Zapi

Aplicación móvil de autoservicio para un kiosco: el cliente escanea o
selecciona productos, arma su carrito y (en el futuro) paga desde el
celular/kiosco. También incluye un panel de administración para
gestionar productos, stock y ver estadísticas de ventas.

## Objetivo de este proyecto

Este repo arrancó como una base arquitectónica para que el equipo (7
personas, sin experiencia previa significativa en Flutter) trabajara en
paralelo, y terminó de cerrarse como demo funcional completa para
entregar. **No** implementa backend, pagos ni autenticación real: todo
eso está simulado con datos mock (no hay servidor propio de Zapi), pero
la app es navegable de punta a punta, incluyendo escaneo de código de
barras con cámara real.

## Tecnologías

- Flutter / Dart
- Material 3
- [`provider`](https://pub.dev/packages/provider) para estado compartido simple (carrito, catálogo de productos)
- [`flutter_svg`](https://pub.dev/packages/flutter_svg) para los íconos/logo de Zapi
- [`mobile_scanner`](https://pub.dev/packages/mobile_scanner) para lectura de códigos de barra
- [`fl_chart`](https://pub.dev/packages/fl_chart) para los gráficos del dashboard
- [`intl`](https://pub.dev/packages/intl) para formateo de precios/fechas

## Arquitectura

Arquitectura por *features* con una capa de datos separada de la UI:

```
lib/
├── app/          -> arranque de la app: routing, tema, Provider (inyección de dependencias)
├── core/
│   ├── constants/  -> constantes generales y URL de la API
│   ├── errors/     -> AppException y derivadas (red, timeout, API, formato)
│   ├── network/    -> ApiClient: único lugar que habla HTTP
│   ├── utils/
│   └── widgets/    -> componentes reutilizables (compartidos por Cliente y Admin)
├── data/
│   ├── models/       -> Product, CartItem, Sale, SalesStats
│   ├── services/     -> ProductService (HTTP real), SalesDataSource (interfaz)
│   ├── repositories/ -> ProductRepository, StatsRepository
│   └── mocks/        -> MockSalesDataSource (ventas simuladas)
├── state/        -> estado compartido (CartController, ProductCatalog)
└── features/
    ├── splash/
    ├── client/   -> cart, scanner, product_list, categories, checkout, ...
    └── admin/    -> login, dashboard, stats (StatsController), products, stock, ...
```

Flujo de datos: `API / mock → Service → Repository → Estado (Provider) → Pantalla`.
Las pantallas nunca llaman a la API ni leen listas mock directamente.

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
- Componentes reutilizables (header, botones, items de lista, buscador, selector de cantidad, scanner).
- Modelos y datos mock realistas.
- Capa de servicios preparada para reemplazar mocks por un backend real sin tocar las pantallas.
- Escaneo de código de barras con **cámara real** (`mobile_scanner`, funciona en Android/iOS/Web/desktop), con un botón "Simular escaneo" de respaldo por si no hay cámara disponible o un producto físico a mano.
- Validación de formularios en Login y Add Product.

## Qué está mockeado

- **Productos**: NO son mock. Vienen de la API real (`https://zapi-rqos.onrender.com/products`: listar, buscar por código y crear).
- **Estadísticas / historial de ventas**: ventas simuladas en `lib/data/mocks/mock_sales_data_source.dart` (volumen bajo, últimos 7 días). Referencian los productos reales por `code`; nombres y precios salen siempre de la API.
- **Autenticación**: el login acepta cualquier valor (valida solo que el formulario esté completo), no valida contra ningún backend.
- **Pago**: el botón "Pagar" en el Scanner es solo visual, no llama a ningún servicio.

## Qué queda pendiente de backend

- Endpoints para **editar, borrar y corregir stock** de productos: hoy esos cambios se guardan solo en memoria durante la sesión (ver `lib/data/repositories/product_repository.dart`, marcados con `TODO(backend)`).
- Endpoint de ventas: reemplazar `MockSalesDataSource` por una implementación HTTP de `SalesDataSource`.
- Autenticación real de administrador.
- Integración de pago (Mercado Pago u otro medio).
- Persistencia real de stock (hoy se actualiza solo en memoria).
- SVG oficiales de Zapi (`assets/svg/`, ver `assets/svg/PLACEHOLDER.md`).
