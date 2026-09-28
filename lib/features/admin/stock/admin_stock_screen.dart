import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/core/widgets/app_search_bar.dart';
import 'package:zapi/core/widgets/primary_button.dart';
import 'package:zapi/core/widgets/product_item.dart';
import 'package:zapi/models/product.dart';
import 'package:zapi/state/product_catalog.dart';

/// Pantalla de stock del administrador (listado rapido + acceso a
/// Stock Review).
///
/// El boton "+" de cada fila es intencionalmente solo informativo (avisa
/// que el ajuste real de stock se hace en "Revisar stock", donde se
/// carga la cantidad contada fisicamente vía `ProductCatalog.updateStock`).
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

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<ProductCatalog>();
    final products = _filter(catalog.products);

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
                child: catalog.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        itemCount: products.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: AppColors.border),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ProductItem(
                            product: product,
                            subtitle: 'Stock: ${product.stock}',
                            trailing: IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  color: AppColors.primary),
                              onPressed: () {
                                // Placeholder visual: el ajuste real de
                                // stock se hace en "Revisar stock".
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Para actualizar el stock usá "Revisar stock"',
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
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
