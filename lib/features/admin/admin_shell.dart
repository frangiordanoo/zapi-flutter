import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/features/admin/dashboard/admin_dashboard_screen.dart';
import 'package:zapi/features/admin/products/admin_products_screen.dart';
import 'package:zapi/features/admin/stats/stats_controller.dart';
import 'package:zapi/features/admin/stock/admin_stock_screen.dart';
import 'package:zapi/features/admin/widgets/admin_bottom_navigation.dart';

/// Contenedor de las 3 secciones principales del administrador
/// (Estadisticas / Productos / Stock).
///
/// Usa un `IndexedStack` en vez de navegar con rutas nuevas para que
/// cada tab mantenga su estado (scroll, busqueda, etc.) al cambiar de
/// seccion, y para que el `AdminBottomNavigation` nunca se destruya ni
/// se duplique.
///
/// La pantalla por defecto al entrar (por ejemplo, justo despues del
/// login) es "Estadisticas" (indice 0), segun lo pedido.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  static const _screens = [
    AdminDashboardScreen(),
    AdminProductsScreen(),
    AdminStockScreen(),
  ];

  void _handleTap(int index) {
    // Las estadisticas dependen de los productos (precios, nombres): se
    // recalculan al volver a la pestaña por si se editaron o crearon.
    if (index == 0 && _currentIndex != 0) {
      context.read<StatsController>().load();
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: AdminBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _handleTap,
      ),
    );
  }
}
