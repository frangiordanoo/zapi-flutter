import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/core/widgets/primary_button.dart';
import 'package:zapi/data/models/product.dart';
import 'package:zapi/data/models/stock_review.dart';
import 'package:zapi/state/product_catalog.dart';

/// Pantalla de revision fisica de stock.
///
/// El administrador carga la cantidad contada de los productos que revisó;
/// al tocar "Aceptar" se manda todo junto a `POST /products/review-stock`.
/// OJO: el backend compara con lo registrado Y deja el stock igual al
/// conteo. Los productos sin cantidad cargada no se envian (no se tocan).
class AdminStockReviewScreen extends StatefulWidget {
  const AdminStockReviewScreen({super.key});

  @override
  State<AdminStockReviewScreen> createState() =>
      _AdminStockReviewScreenState();
}

class _AdminStockReviewScreenState extends State<AdminStockReviewScreen> {
  final Map<int, TextEditingController> _controllers = {};
  bool _submitting = false;

  TextEditingController _controllerFor(Product product) {
    return _controllers.putIfAbsent(
      product.id,
      () => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleAccept(List<Product> products) async {
    if (_submitting) return;

    final counts = <StockCount>[];
    for (final product in products) {
      final text = _controllers[product.id]?.text.trim();
      if (text == null || text.isEmpty) continue;
      final counted = int.tryParse(text);
      if (counted == null || counted < 0) {
        _showMessage('La cantidad de "${product.name}" debe ser un entero de 0 o más.');
        return;
      }
      counts.add(StockCount(code: product.code, physicalStock: counted));
    }

    if (counts.isEmpty) {
      _showMessage('Cargá la cantidad de al menos un producto.');
      return;
    }

    final catalog = context.read<ProductCatalog>();
    setState(() => _submitting = true);
    try {
      final results = await catalog.reviewStock(counts);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => _ReviewResultDialog(results: results),
      );
      if (mounted) Navigator.of(context).pop();
    } on AppException catch (e) {
      if (mounted) _showMessage(e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<ProductCatalog>();
    final products = catalog.stockProducts;

    return Scaffold(
      appBar: const AppHeader(title: 'Revisión de Stock', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name, style: AppTextStyles.bodyBold),
                                const SizedBox(height: 2),
                                Text('Stock: ${product.stock}',
                                    style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 90,
                            child: TextField(
                              controller: _controllerFor(product),
                              enabled: !_submitting,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                hintText: 'Stock actual',
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              if (_submitting)
                const CircularProgressIndicator()
              else
                PrimaryButton(
                  label: 'Aceptar',
                  onPressed: () => _handleAccept(products),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Resumen de la revision: cuantos coinciden y el detalle de los que no.
class _ReviewResultDialog extends StatelessWidget {
  const _ReviewResultDialog({required this.results});

  final List<StockReviewResult> results;

  @override
  Widget build(BuildContext context) {
    final differences =
        results.where((r) => r.status != StockReviewStatus.correct).toList();
    final correctCount = results.length - differences.length;

    return AlertDialog(
      title: const Text('Revisión completada'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$correctCount de ${results.length} productos coinciden.'),
            if (differences.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Diferencias (el stock quedó igual al conteo):',
                  style: AppTextStyles.bodyBold),
              const SizedBox(height: 8),
              for (final r in differences)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '${r.name}: ${r.databaseStock} → ${r.physicalStock} '
                    '(${r.status == StockReviewStatus.missing ? 'faltan' : 'sobran'} '
                    '${r.difference})',
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Listo'),
        ),
      ],
    );
  }
}
