import 'package:zapi/data/models/sale.dart';
import 'package:zapi/data/services/sales_data_source.dart';

// Codigos de productos que EXISTEN en la API de Zapi. Las ventas solo
// guardan el codigo: nombre, precio y categoria se toman siempre de la API.
// Si alguno desaparece del catalogo, esa linea se ignora al armar las
// estadisticas (ver StatsRepository).
const _agua = '7909883138066';
const _papas = '7798161902198';
const _alfajorJorgito = '7790387800142';
const _chocolateMilka = '7790580144364';
const _galletitasOreo = '7791813888468';
const _aguaVillavicencio = '7790150260661';
const _cafe = '7790150101773';
const _yerba = '7790710334603';
const _galletitasRex = '7790040719804';
const _galletasPepitos = '7622201735883';
const _galletasOreo = '7622201735258';
const _off = '7793253006792';
const _talco = '7791520009712';

/// Ventas simuladas de los ultimos 7 dias, con el volumen bajo de un
/// kiosco que recien empieza (1 a 3 ventas por dia, 1 a 4 unidades cada
/// una). Las fechas son relativas a "hoy" para que el dashboard siempre
/// muestre la semana en curso.
///
/// No genera ninguna escritura sobre los productos: vender en el mock NO
/// modifica el stock real de la API.
class MockSalesDataSource implements SalesDataSource {
  MockSalesDataSource({
    DateTime Function()? clock,
    this.latency = const Duration(milliseconds: 250),
  }) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final Duration latency;

  @override
  Future<List<Sale>> fetchSales() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    final now = _clock();

    Sale sale(int id, int daysAgo, int hour, int minute, String payment,
        List<(String, int)> lines) {
      return Sale(
        id: id,
        date: _at(now, daysAgo, hour, minute),
        paymentMethod: payment,
        items: [for (final (code, qty) in lines) SaleItem(productCode: code, quantity: qty)],
      );
    }

    return [
      sale(101, 6, 11, 20, 'Efectivo', [(_agua, 1), (_alfajorJorgito, 2)]),
      sale(102, 6, 18, 5, 'Mercado Pago', [(_papas, 1), (_chocolateMilka, 1)]),
      sale(103, 5, 10, 40, 'Tarjeta', [(_galletitasOreo, 2), (_aguaVillavicencio, 1)]),
      sale(104, 5, 16, 30, 'Efectivo', [(_yerba, 1)]),
      sale(105, 4, 9, 50, 'Mercado Pago', [(_cafe, 1), (_galletasPepitos, 2)]),
      sale(106, 4, 13, 15, 'Efectivo', [(_alfajorJorgito, 1), (_agua, 1)]),
      sale(107, 4, 19, 25, 'Tarjeta', [(_papas, 2), (_aguaVillavicencio, 2)]),
      sale(108, 3, 12, 10, 'Mercado Pago', [(_galletitasRex, 1), (_galletasOreo, 1)]),
      sale(109, 3, 17, 40, 'Efectivo', [(_chocolateMilka, 1), (_alfajorJorgito, 3)]),
      sale(110, 2, 15, 0, 'Tarjeta', [(_talco, 1), (_off, 1)]),
      sale(111, 1, 10, 25, 'Efectivo', [(_agua, 2), (_galletasPepitos, 1)]),
      sale(112, 1, 14, 50, 'Mercado Pago', [(_yerba, 1), (_cafe, 1), (_alfajorJorgito, 1)]),
      sale(113, 1, 20, 10, 'Tarjeta', [(_galletitasOreo, 1), (_papas, 1)]),
      sale(114, 0, 11, 30, 'Efectivo', [(_aguaVillavicencio, 1), (_alfajorJorgito, 2)]),
      sale(115, 0, 18, 0, 'Mercado Pago', [(_agua, 1), (_chocolateMilka, 1)]),
    ].reversed.toList();
  }

  /// Para los dias anteriores usa la hora indicada. Para "hoy" reparte la
  /// hora proporcionalmente sobre lo que va transcurrido del dia, asi nunca
  /// queda una venta en el futuro.
  static DateTime _at(DateTime now, int daysAgo, int hour, int minute) {
    if (daysAgo > 0) {
      return DateTime(now.year, now.month, now.day - daysAgo, hour, minute);
    }
    final startOfDay = DateTime(now.year, now.month, now.day);
    final elapsedMinutes = now.difference(startOfDay).inMinutes;
    final fractionOfDay = (hour * 60 + minute) / (24 * 60);
    return startOfDay.add(Duration(minutes: (elapsedMinutes * fractionOfDay).floor()));
  }
}
