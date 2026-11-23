import 'package:zapi/core/errors/app_exception.dart';

/// Conteo fisico de un producto que se manda a `POST /products/review-stock`.
class StockCount {
  final String code;
  final int physicalStock;

  const StockCount({required this.code, required this.physicalStock});

  Map<String, dynamic> toJson() => {'code': code, 'physicalStock': physicalStock};
}

enum StockReviewStatus {
  /// El stock fisico coincide con el registrado.
  correct,

  /// Hay menos unidades fisicas que las registradas (faltante).
  missing,

  /// Hay mas unidades fisicas que las registradas (sobrante).
  surplus,
}

/// Resultado de la revision de un producto. OJO: el backend, ademas de
/// comparar, **deja el stock registrado igual al fisico** (sincroniza).
class StockReviewResult {
  final String code;
  final String name;
  final int databaseStock;
  final int physicalStock;
  final int difference;
  final StockReviewStatus status;

  const StockReviewResult({
    required this.code,
    required this.name,
    required this.databaseStock,
    required this.physicalStock,
    required this.difference,
    required this.status,
  });

  factory StockReviewResult.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    final status = switch (json['status']) {
      'correct' => StockReviewStatus.correct,
      'missing' => StockReviewStatus.missing,
      'surplus' => StockReviewStatus.surplus,
      _ => null,
    };
    final database = json['databaseStock'];
    final physical = json['physicalStock'];
    if (product is! Map ||
        product['code'] == null ||
        status == null ||
        database is! num ||
        physical is! num) {
      throw const DataFormatException('Un resultado de la revisión de stock es inválido.');
    }
    return StockReviewResult(
      code: product['code'].toString(),
      name: product['name']?.toString() ?? product['code'].toString(),
      databaseStock: database.toInt(),
      physicalStock: physical.toInt(),
      difference: (json['difference'] as num?)?.toInt() ?? (physical - database).abs().toInt(),
      status: status,
    );
  }
}
