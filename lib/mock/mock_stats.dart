/// Datos mock para el dashboard de estadisticas del administrador.
///
/// Todo esto es ficticio. Cuando exista el endpoint real de estadisticas,
/// esta clase se reemplaza (o se llena) con la respuesta del backend sin
/// tener que tocar la pantalla `AdminDashboardScreen`.
class MockStats {
  static const double totalSales = 458300;
  static const int totalOrders = 213;
  static const int productsSold = 587;
  static const String bestSellingProduct = 'Coca Cola 500ml';
  static const double todaySales = 18400;

  /// Ventas por dia de la semana (Lun a Dom), para el grafico de barras.
  static const Map<String, double> salesByWeekday = {
    'Lun': 42000,
    'Mar': 38500,
    'Mie': 51000,
    'Jue': 47500,
    'Vie': 68000,
    'Sab': 72300,
    'Dom': 39000,
  };

  /// Productos mas vendidos (nombre -> unidades vendidas).
  static const Map<String, int> topProducts = {
    'Coca Cola 500ml': 120,
    'Alfajor Milka': 95,
    'Papas Lay\'s Clasicas': 80,
    'Agua Mineral 500ml': 64,
  };
}
