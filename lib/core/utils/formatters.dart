import 'package:intl/intl.dart';

/// Utilidades de formateo compartidas. Si necesitas formatear un precio
/// o una fecha en una pantalla nueva, usa estas funciones en vez de
/// escribir el formato a mano de nuevo.
class Formatters {
  Formatters._();

  // Se usa un patron numerico simple (sin locale de moneda especifico)
  // para no depender de que el paquete intl tenga cargados los datos de
  // un locale regional puntual: alcanza con el separador de miles.
  static final NumberFormat _thousands = NumberFormat('#,##0');

  /// Formatea un precio como "$1,700".
  static String currency(num value) => '\$${_thousands.format(value)}';

  static final DateFormat _date = DateFormat('dd/MM/yyyy');

  static String date(DateTime value) => _date.format(value);
}
