import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/core/widgets/app_search_bar.dart';
import 'package:zapi/core/widgets/primary_button.dart';
import 'package:zapi/core/widgets/product_item.dart';
import 'package:zapi/models/product.dart';
import 'package:zapi/state/cart_controller.dart';
import 'package:zapi/state/product_catalog.dart';

/// Lista de productos disponibles para que el cliente arme su compra
/// sin usar la camara.
///
/// Si recibe un [categoryFilter] (via `arguments` de la ruta, ver
/// lib/features/client/categories/client_categories_screen.dart) solo
/// muestra los productos de esa categoria.
class ClientProductListScreen extends StatefulWidget {
  const ClientProductListScreen({super.key, this.categoryFilter});

  final String? categoryFilter;

  @override
  State<ClientProductListScreen> createState() =>
      _ClientProductListScreenState();
}

class _ClientProductListScreenState extends State<ClientProductListScreen> {
  String _query = '';

  List<Product> _filter(List<Product> products) {
    var result = products;
    if (widget.categoryFilter != null) {
      result = result.where((p) => p.category == widget.categoryFilter).toList();
    }
    if (_query.trim().isEmpty) return result;
    final query = _query.toLowerCase();
    return result.where((p) => p.name.toLowerCase().contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<ProductCatalog>();
    final cart = context.watch<CartController>();
    final products = _filter(catalog.products);

    return Scaffold(
      appBar: AppHeader(title: widget.categoryFilter ?? 'Productos', light: true),
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
                          final added = cart.contains(product.id);
                          return InkWell(
                            onTap: () => Navigator.pushNamed(
                              context,
                              RouteNames.clientProductDetail,
                              arguments: product,
                            ),
                            child: ProductItem(
                              product: product,
                              trailing: _AddButton(
                                added: added,
                                onPressed: () =>
                                    context.read<CartController>().addProduct(product),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Continuar',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.added, required this.onPressed});

  final bool added;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: added ? AppColors.success : AppColors.primary,
        minimumSize: const Size(90, 36),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      child: Text(added ? 'Añadido' : 'Añadir'),
    );
  }
}
