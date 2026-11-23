import 'package:zapi/data/models/sale.dart';

/// Las ventas pagadas de un mismo dia, como las muestra el historial del
/// administrador (igual que `SaleHistoryDay` del frontend web).
///
/// El dia y la hora se calculan SIEMPRE en hora de Argentina (UTC-3, el
/// pais no tiene horario de verano), igual que hace el backend al agrupar
/// (`America/Argentina/Mendoza`), sin importar la zona del telefono.
class SalesHistoryDay {
  final DateTime day;
  final List<Sale> sales;

  const SalesHistoryDay({required this.day, required this.sales});

  int get totalSales => sales.length;

  double get totalAmount => sales.fold(0, (sum, sale) => sum + sale.total);

  /// Agrupa las ventas por dia de pago: dias del mas reciente al mas
  /// antiguo y, dentro de cada dia, la venta mas reciente primero.
  static List<SalesHistoryDay> group(List<Sale> sales) {
    final byDay = <DateTime, List<Sale>>{};
    for (final sale in sales) {
      final key = _dayOf(argentinaTime(sale.date));
      byDay.putIfAbsent(key, () => []).add(sale);
    }
    final days = [
      for (final entry in byDay.entries)
        SalesHistoryDay(
          day: entry.key,
          sales: [...entry.value]..sort((a, b) => b.date.compareTo(a.date)),
        ),
    ]..sort((a, b) => b.day.compareTo(a.day));
    return days;
  }

  /// "Hoy", "Ayer" o la fecha completa ("23 de noviembre de 2026").
  String label(DateTime now) {
    final today = _dayOf(argentinaTime(now));
    if (day == today) return 'Hoy';
    if (day == DateTime.utc(today.year, today.month, today.day - 1)) return 'Ayer';
    return '${day.day} de ${_months[day.month - 1]} de ${day.year}';
  }

  /// Un instante, expresado como reloj de pared de Argentina (se lee con
  /// los getters `.hour`, `.day`, etc. como si fuera UTC).
  static DateTime argentinaTime(DateTime instant) =>
      instant.toUtc().subtract(const Duration(hours: 3));

  /// "14:05", la hora de pago en Argentina.
  static String clock(DateTime instant) {
    final t = argentinaTime(instant);
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  static DateTime _dayOf(DateTime argentinaWallClock) => DateTime.utc(
        argentinaWallClock.year,
        argentinaWallClock.month,
        argentinaWallClock.day,
      );

  static const _months = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
}
