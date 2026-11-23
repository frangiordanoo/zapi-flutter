import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/core/errors/app_exception.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/core/widgets/app_search_bar.dart';
import 'package:zapi/core/widgets/catalog_content.dart';
import 'package:zapi/core/widgets/product_item.dart';
import 'package:zapi/features/admin/products/widgets/delete_product_dialog.dart';
import 'package:zapi/features/admin/products/widgets/edit_product_dialog.dart';
import 'package:zapi/data/models/product.dart';
import 'package:zapi/state/product_catalog.dart';

/// Pantalla de administracion de productos: buscar, editar (nombre y
/// precio, via [EditProductDialog] -> `PUT /products/:code`), ocultar
/// (borrado logico, via [DeleteProductDialog] -> `PATCH /products/:code`),
/// recuperar un producto oculto (`PATCH /products/:code/restore`) y navegar
/// a Add Product con el boton flotante "+".
///
/// Lista TODOS los productos (`GET /products/all`): los ocultos aparecen
/// atenuados con un boton para recuperarlos.
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

  void _showError(AppException e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
  }

  Future<void> _handleEdit(Product product) async {
    final updated = await showDialog<Product>(
      context: context,
      builder: (_) => EditProductDialog(product: product),
    );
    if (updated == null || !mounted) return;
    try {
      await context.read<ProductCatalog>().updateProduct(updated);
    } on AppException catch (e) {
      if (mounted) _showError(e);
    }
  }

  Future<void> _handleHide(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const DeleteProductDialog(),
    );
    if (confirmed != true || !mounted) return;
    try {
      await context.read<ProductCatalog>().hideProduct(product);
    } on AppException catch (e) {
      if (mounted) _showError(e);
    }
  }

  Future<void> _handleRestore(Product product) async {
    try {
      await context.read<ProductCatalog>().restoreProduct(product);
    } on AppException catch (e) {
      if (mounted) _showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<ProductCatalog>();
    final products = _filter(catalog.adminProducts);

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
                child: CatalogContent(
                  catalog: catalog,
                  admin: true,
                  child: ListView.separated(
                    itemCount: products.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return InkWell(
                        onTap: () => Navigator.pushNamed(
                          context,
                          RouteNames.adminProductDetail,
                          arguments: product,
                        ),
                        child: Opacity(
                          opacity: product.isActive ? 1 : 0.5,
                          child: ProductItem(
                            product: product,
                            subtitle: product.isActive ? null : 'Oculto',
                            trailing: product.isActive
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Editar',
                                        icon: const Icon(Icons.edit_outlined,
                                            color: AppColors.primary),
                                        onPressed: () => _handleEdit(product),
                                      ),
                                      IconButton(
                                        tooltip: 'Ocultar',
                                        icon: const Icon(Icons.visibility_off_outlined,
                                            color: AppColors.danger),
                                        onPressed: () => _handleHide(product),
                                      ),
                                    ],
                                  )
                                : IconButton(
                                    tooltip: 'Recuperar',
                                    icon: const Icon(Icons.restore,
                                        color: AppColors.primary),
                                    onPressed: () => _handleRestore(product),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
