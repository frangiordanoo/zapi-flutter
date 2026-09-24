import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/core/widgets/app_search_bar.dart';
import 'package:zapi/core/widgets/primary_button.dart';
import 'package:zapi/core/widgets/product_item.dart';
import 'package:zapi/models/product.dart';
import 'package:zapi/state/cart_controller.dart';
import 'package:zapi/state/product_catalog.dart';

// ============================================================
// RESPONSABLE: Fran
//
// TAREA:
// Pantalla de lista de productos del cliente, con seleccion multiple y
// vuelta al carrito.
//
// OBJETIVO:
// Mostrar todos los productos disponibles (ProductCatalog, hoy con
// datos mock). Cada fila tiene un boton "Añadir" que al tocarlo agrega
// el producto al carrito compartido (CartController) y cambia su
// propio estado visual a "Añadido" (deshabilitado / otro color). El
// boton "Continuar" al final vuelve a la pantalla del carrito.
//
// DEBE UTILIZAR:
// - AppHeader, AppSearchBar, ProductItem, PrimaryButton
// - CartController y ProductCatalog (Provider)
//
// NO DEBE HACER:
// - Llamadas al backend (ProductCatalog ya abstrae eso).
//
// POSTERIORMENTE:
// Cuando ProductCatalog use un ApiProductService en vez de
// MockProductService, esta pantalla no deberia necesitar cambios.
//
// PROMPT PARA IA:
//
// "Estoy trabajando en una app Flutter (Material 3, Provider) llamada
// Zapi. Tengo la pantalla
// lib/features/client/product_list/client_product_list_screen.dart
// (ClientProductListScreen) que muestra una lista de productos leida
// de un ProductCatalog (ChangeNotifier, context.watch<ProductCatalog>())
// usando el widget ProductItem
// (lib/core/widgets/product_item.dart) con un boton 'Añadir' como
// trailing. Quiero que mejores la UX: que el buscador (AppSearchBar)
// filtre la lista por nombre en tiempo real, que el boton 'Añadir' de
// cada fila cambie visualmente a 'Añadido' (por ejemplo con otro color
// de fondo) cuando ese producto ya esta en el carrito
// (CartController.contains(productId)), y que se pueda volver a
// quitar. El boton 'Continuar' de abajo de todo debe hacer
// Navigator.pop(context) para volver al carrito. No cambies como se
// obtienen los productos (siempre via ProductCatalog)."
// ============================================================

/// Lista de productos disponibles para que el cliente arme su compra
/// sin usar la camara.
class ClientProductListScreen extends StatefulWidget {
  const ClientProductListScreen({super.key});

  @override
  State<ClientProductListScreen> createState() =>
      _ClientProductListScreenState();
}

class _ClientProductListScreenState extends State<ClientProductListScreen> {
  String _query = '';

  List<Product> _filter(List<Product> products) {
    if (_query.trim().isEmpty) return products;
    final query = _query.toLowerCase();
    return products.where((p) => p.name.toLowerCase().contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<ProductCatalog>();
    final cart = context.watch<CartController>();
    final products = _filter(catalog.products);

    return Scaffold(
      appBar: const AppHeader(title: 'Productos', light: true),
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
                          return ProductItem(
                            product: product,
                            trailing: _AddButton(
                              added: added,
                              onPressed: () =>
                                  context.read<CartController>().addProduct(product),
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
