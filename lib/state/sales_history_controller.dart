import 'package:flutter/foundation.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/data/models/sales_history_day.dart';
import 'package:zapi/data/services/sales_data_source.dart';

/// Estado del historial de ventas del administrador: las ventas PAGADAS que
/// devuelve el backend (`GET /sales/history`), agrupadas por dia.
///
/// Es independiente de las estadisticas (`StatsController`): el backend
/// todavia no tiene estadisticas, asi que esas siguen simuladas; el
/// historial en cambio es real.
class SalesHistoryController extends ChangeNotifier {
  SalesHistoryController(this._source);

  final SalesDataSource _source;

  List<SalesHistoryDay>? days;
  bool isLoading = false;
  String? errorMessage;

  /// Descarta los datos (al cerrar sesion).
  void clear() {
    days = null;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> load() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();
    try {
      days = SalesHistoryDay.group(await _source.fetchSales());
      errorMessage = null;
    } on AppException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
