import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/core/widgets/app_search_bar.dart';
import 'package:zapi/core/widgets/product_item.dart';
import 'package:zapi/features/admin/products/widgets/delete_product_dialog.dart';
import 'package:zapi/features/admin/products/widgets/edit_product_dialog.dart';
import 'package:zapi/models/product.dart';
import 'package:zapi/state/product_catalog.dart';

/// Pantalla de administracion de productos: buscar, editar (nombre y
/// precio, via [EditProductDialog]), borrar (soft delete, via
/// [DeleteProductDialog] + `ProductCatalog.softDeleteProduct`, nunca se
/// borra de verdad) y navegar a Add Product con el boton flotante "+".
class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  String _query = '';

  List<Product> _filter(List<Product> products) {
    if (_query.trim().isEmpty) return products;
    final query = _query.toLowerCase();
    return products.where((p) => p.name.toLowerCase().contains(query)).toList();
  }

  Future<void> _handleEdit(Product product) async {
    final updated = await showDialog<Product>(
      context: context,
      builder: (_) => EditProductDialog(product: product),
    );
    if (updated == null || !mounted) return;
    await context.read<ProductCatalog>().updateProduct(updated);
  }

  Future<void> _handleDelete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const DeleteProductDialog(),
    );
    if (confirmed != true || !mounted) return;
    await context.read<ProductCatalog>().softDeleteProduct(product.id);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<ProductCatalog>();
    final products = _filter(catalog.products);

    return Scaffold(
      appBar: const AppHeader(title: 'Productos', light: true),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () =>
            Navigator.pushNamed(context, RouteNames.adminAddProduct),
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      color: AppColors.primary),
                                  onPressed: () => _handleEdit(product),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: AppColors.danger),
                                  onPressed: () => _handleDelete(product),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
