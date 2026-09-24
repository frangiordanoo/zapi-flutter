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

// ============================================================
// RESPONSABLE: Renzo
//
// TAREA:
// Pantalla de stock del administrador (listado rapido + acceso a
// Stock Review).
//
// OBJETIVO:
// Mostrar todos los productos con su stock actual y un buscador. El
// boton "+" de cada fila HOY no hace nada (ver mas abajo el porque). Al
// final, el boton "Revisar stock" navega a Stock Review
// (RouteNames.adminStockReview), donde si se puede actualizar el stock
// de verdad.
//
// DEBE UTILIZAR:
// - AppHeader, AppSearchBar, ProductItem, PrimaryButton
// - ProductCatalog (Provider) para leer productos y su stock
//
// NO DEBE HACER:
// - Sumar/restar stock desde el boton "+" de esta pantalla (ver nota).
//
// NOTA SOBRE EL BOTON "+":
// Segun la consigna original, el "+" de esta lista es solo visual por
// ahora (no dispara ninguna accion). El ajuste real de stock se hace en
// Stock Review, donde se carga la cantidad contada fisicamente. Si el
// equipo decide que este "+" debe hacer algo (por ejemplo sumar 1 de
// stock rapido), documentarlo aca y conectar con
// ProductCatalog.updateStock.
//
// PROMPT PARA IA:
//
// "Estoy trabajando en una app Flutter (Material 3, Provider) llamada
// Zapi. Tengo la pantalla lib/features/admin/stock/admin_stock_screen.dart
// (AdminStockScreen) que lista productos con su stock actual desde un
// ProductCatalog (ChangeNotifier), con un buscador (AppSearchBar) y un
// boton 'Revisar stock' (PrimaryButton) que navega a
// RouteNames.adminStockReview. Cada fila tiene un boton '+' que hoy no
// hace nada (es un placeholder visual). Quiero que revises el diseño
// de la lista (ProductItem con el stock como subtitle) y, si te parece
// una buena mejora de UX, le agregues un mensaje/snackbar breve al
// tocar el '+' indicando que el ajuste de stock se hace en 'Revisar
// stock', en vez de dejarlo sin ningun feedback. No implementes ahi
// mismo una logica real de sumar stock."
// ============================================================

/// Pantalla de stock del administrador.
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
