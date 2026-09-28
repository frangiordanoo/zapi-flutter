import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/core/widgets/primary_button.dart';
import 'package:zapi/models/product.dart';
import 'package:zapi/state/product_catalog.dart';

/// Pantalla de revision fisica de stock.
///
/// Al tocar "Aceptar" actualiza el stock de cada producto modificado
/// via `ProductCatalog.updateStock`. Cuando exista backend, esto deberia
/// mandar la cantidad fisica contada a un endpoint real (por ejemplo un
/// PATCH por producto o un endpoint batch) en vez de actualizar el
/// catalogo local directamente.
class AdminStockReviewScreen extends StatefulWidget {
  const AdminStockReviewScreen({super.key});

  @override
  State<AdminStockReviewScreen> createState() =>
      _AdminStockReviewScreenState();
}

class _AdminStockReviewScreenState extends State<AdminStockReviewScreen> {
  final Map<int, TextEditingController> _controllers = {};

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

  Future<void> _handleAccept(List<Product> products) async {
    final catalog = context.read<ProductCatalog>();
    for (final product in products) {
      final text = _controllers[product.id]?.text.trim();
      if (text == null || text.isEmpty) continue;
      final counted = int.tryParse(text);
      if (counted == null) continue;
      await catalog.updateStock(product.id, counted);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stock actualizado')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<ProductCatalog>();
    final products = catalog.products;

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
