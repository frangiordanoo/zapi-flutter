import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/state/product_catalog.dart';

/// Pantalla de categorías: agrupa los productos por [Product.category]
/// para que el cliente pueda navegar antes de ver la lista completa.
class ClientCategoriesScreen extends StatelessWidget {
  const ClientCategoriesScreen({super.key});

  static const _icons = {
    'Bebidas': Icons.local_drink_outlined,
    'Golosinas': Icons.icecream_outlined,
    'Snacks': Icons.cookie_outlined,
    'Almacen': Icons.kitchen_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<ProductCatalog>();
    final categories = catalog.products.map((p) => p.category).toSet().toList()..sort();

    return Scaffold(
      appBar: const AppHeader(title: 'Categorías', light: true),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final count = catalog.products.where((p) => p.category == category).length;
            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => Navigator.pushNamed(
                context,
                RouteNames.clientProductList,
                arguments: category,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_icons[category] ?? Icons.category_outlined,
                        size: 36, color: AppColors.primary),
                    const SizedBox(height: 10),
                    Text(category, style: AppTextStyles.bodyBold),
                    const SizedBox(height: 4),
                    Text('$count productos', style: AppTextStyles.caption),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
