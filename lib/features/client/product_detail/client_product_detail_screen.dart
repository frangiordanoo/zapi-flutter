import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/utils/formatters.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/core/widgets/primary_button.dart';
import 'package:zapi/core/widgets/quantity_selector.dart';
import 'package:zapi/models/product.dart';
import 'package:zapi/state/cart_controller.dart';

/// Vista de detalle de un producto para el cliente. Se llega tocando una
/// fila de [lib/features/client/product_list/client_product_list_screen.dart].
///
/// Recibe el [Product] a mostrar como `arguments` de la ruta.
class ClientProductDetailScreen extends StatefulWidget {
  const ClientProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ClientProductDetailScreen> createState() => _ClientProductDetailScreenState();
}

class _ClientProductDetailScreenState extends State<ClientProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppHeader(title: product.name, showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1.4,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.local_grocery_store_outlined,
                      size: 72, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 20),
              Text(product.name, style: AppTextStyles.screenTitle),
              const SizedBox(height: 6),
              Text('Categoría: ${product.category}', style: AppTextStyles.caption),
              const SizedBox(height: 12),
              Text(Formatters.currency(product.price), style: AppTextStyles.price),
              const SizedBox(height: 8),
              Text(
                product.stock > 0 ? 'Stock disponible: ${product.stock}' : 'Sin stock',
                style: AppTextStyles.body.copyWith(
                  color: product.stock > 0 ? AppColors.success : AppColors.danger,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Cantidad', style: AppTextStyles.bodyBold),
                  QuantitySelector(
                    quantity: _quantity,
                    onIncrement: () => setState(() => _quantity++),
                    onDecrement: () => setState(() {
                      if (_quantity > 1) _quantity--;
                    }),
                  ),
                ],
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Agregar al carrito',
                icon: Icons.add_shopping_cart,
                onPressed: () {
                  final cart = context.read<CartController>();
                  for (var i = 0; i < _quantity; i++) {
                    cart.addProduct(product);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.name} agregado al carrito')),
                  );
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
