# Zapi

Aplicación móvil de autoservicio para un kiosco: el cliente escanea o
selecciona productos, arma su carrito y (en el futuro) paga desde el
celular/kiosco. También incluye un panel de administración para
gestionar productos, stock y ver estadísticas de ventas.

## Objetivo de este proyecto

Este repo arrancó como una base arquitectónica para que el equipo (7
personas, sin experiencia previa significativa en Flutter) trabajara en
paralelo, y terminó de cerrarse como demo funcional completa para
entregar. Hoy es el cliente Flutter del backend real de Zapi (login con
JWT, productos, stock, pago con Mercado Pago e historial de ventas; ver
"Integración con el backend") y mantiene el escaneo de código de barras
con cámara real.

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

- Login real contra el backend (solo usuarios con rol ADMIN).
- Dashboard de estadísticas (ventas, producto más vendido, gráficos). **Con datos simulados**:
  el backend todavía no tiene estadísticas.
- Historial de ventas real, agrupado por día (Hoy / Ayer / fecha) con el total de cada día.
- Gestión de productos: buscar, editar (nombre/precio), ocultar y recuperar.
- Gestión de stock: sumar unidades y hacer una revisión física.
- Alta de productos nuevos, con escaneo de código de barras.

## Integración con el backend

La app consume el backend real (`https://zapi-rqos.onrender.com`, repo
[palavecino12/Zapi](https://github.com/palavecino12/Zapi), carpeta `backend/`).
Todo pasa por un único `ApiClient`, que agrega `Authorization: Bearer <token>`
cuando hay sesión de administrador.

| Función en la app | Endpoint |
|---|---|
| Login admin (solo rol ADMIN) | `POST /auth/login` |
| Catálogo del cliente / búsqueda por código | `GET /products`, `GET /products/:code` |
| Catálogo completo del admin (con ocultos y sin stock) | `GET /products/all` |
| Alta / edición (nombre y precio) | `POST /products`, `PUT /products/:code` |
| Ocultar / recuperar producto | `PATCH /products/:code`, `PATCH /products/:code/restore` |
| Sumar stock | `PATCH /products/:code/stock` |
| Revisión física de stock (**también actualiza el stock**) | `POST /products/review-stock` |
| Pagar | `POST /sales/checkout` -> abre la URL de Mercado Pago |
| Historial de ventas pagadas | `GET /sales/history` (responde `{"history": [...]}`) |
| Estadísticas del dashboard | **Ninguno: simuladas** (`MockSalesDataSource`) |

Cosas a tener en cuenta:

- **El pago no se puede confirmar desde la app.** El backend lo confirma por webhook de
  Mercado Pago y recién ahí descuenta el stock; no existe un endpoint para consultar el
  estado de una venta. Por eso, tras abrir Mercado Pago la app muestra "Completá tu pago",
  no "compra exitosa".
- La sesión de admin vive solo en memoria (el token dura 8 h): al cerrar la app hay que volver a loguearse.
  Si el servidor responde 401 (token vencido), la app cierra la sesión y vuelve al login, igual que el
  frontend web.
- **Las estadísticas siguen simuladas a propósito.** `/sales/statistics` existe pero el backend indica que
  no funciona, así que el dashboard usa ventas de ejemplo (`lib/data/mocks/`) hasta que el backend las
  ofrezca. El historial de ventas, en cambio, es real.
- El día y la hora del historial se muestran en hora de Argentina (UTC-3), igual que el backend al agrupar.
- Los nombres y precios del historial son los del momento de la venta (`priceAtSale`).
- Validaciones como el backend: el precio de un producto debe ser mayor que 0; al editar, el nombre
  lleva de 2 a 100 caracteres.

## Qué queda pendiente

- Persistir la sesión (por ejemplo con `flutter_secure_storage`).
- Que el backend exponga el estado de una venta para poder confirmar el pago en la app.
- Proteger `/sales/history` en el backend (hoy no exige token).
- SVG oficiales de Zapi (`assets/svg/`, ver `assets/svg/PLACEHOLDER.md`).
