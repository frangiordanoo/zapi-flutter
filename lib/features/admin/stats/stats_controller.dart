import 'package:flutter/foundation.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/data/models/sales_stats.dart';
import 'package:zapi/data/repositories/stats_repository.dart';

/// Estado de las estadisticas del administrador (dashboard, historial de
/// ventas y detalle de producto leen del mismo [stats]).
class StatsController extends ChangeNotifier {
  StatsController(this._repository);

  final StatsRepository _repository;

  SalesStats? stats;
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();
    try {
      stats = await _repository.getStats();
      errorMessage = null;
    } on AppException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
