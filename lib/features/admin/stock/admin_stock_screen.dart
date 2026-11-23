import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/core/widgets/app_search_bar.dart';
import 'package:zapi/core/widgets/catalog_content.dart';
import 'package:zapi/core/widgets/primary_button.dart';
import 'package:zapi/core/widgets/product_item.dart';
import 'package:zapi/data/models/product.dart';
import 'package:zapi/features/admin/stock/widgets/add_stock_dialog.dart';
import 'package:zapi/state/product_catalog.dart';

/// Pantalla de stock del administrador.
///
/// - El boton "+" de cada fila SUMA unidades al stock
///   (`PATCH /products/:code/stock`, via [AddStockDialog]).
/// - "Revisar stock" abre el conteo fisico, que deja el stock igual a lo
///   contado (`POST /products/review-stock`).
///
/// Lista los productos activos incluidos los que tienen stock 0.
class AdminStockScreen extends StatefulWidget {
  const AdminStockScreen({super.key});

  @override
  State<AdminStockScreen> createState() => _AdminStockScreenState();
}

class _AdminStockScreenState extends State<AdminStockScreen> {
  String _query = '';

  List<Product> _filter(List<Product> products) {
    if (_query.trim().isEmpty) return products;
    final query = _query.toLowerCase();
    return products.where((p) => p.name.toLowerCase().contains(query)).toList();
  }

  Future<void> _handleAddStock(Product product) async {
    final quantity = await showDialog<int>(
      context: context,
      builder: (_) => AddStockDialog(product: product),
    );
    if (quantity == null || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<ProductCatalog>().addStock(product, quantity);
      messenger.showSnackBar(
        SnackBar(content: Text('Se agregaron $quantity unidades a ${product.name}')),
      );
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<ProductCatalog>();
    final products = _filter(catalog.stockProducts);

    return Scaffold(
      appBar: const AppHeader(title: 'Stocks', light: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AppSearchBar(onChanged: (value) => setState(() => _query = value)),
              const SizedBox(height: 12),
              Expanded(
                child: CatalogContent(
                  catalog: catalog,
                  admin: true,
                  child: ListView.separated(
                    itemCount: products.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductItem(
                        product: product,
                        subtitle: 'Stock: ${product.stock}',
                        trailing: IconButton(
                          tooltip: 'Agregar stock',
                          icon: const Icon(Icons.add_circle_outline,
                              color: AppColors.primary),
                          onPressed: () => _handleAddStock(product),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Revisar stock',
                icon: Icons.fact_check_outlined,
                onPressed: () =>
                    Navigator.pushNamed(context, RouteNames.adminStockReview),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
