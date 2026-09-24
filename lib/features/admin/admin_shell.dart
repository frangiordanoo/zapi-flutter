import 'package:flutter/material.dart';
import 'package:zapi/features/admin/dashboard/admin_dashboard_screen.dart';
import 'package:zapi/features/admin/products/admin_products_screen.dart';
import 'package:zapi/features/admin/stock/admin_stock_screen.dart';
import 'package:zapi/features/admin/widgets/admin_bottom_navigation.dart';

// ============================================================
// RESPONSABLE: Facundo Palavecino
//
// Este archivo es parte de la estructura GLOBAL del admin (routing +
// navegacion), no de una pantalla individual. En principio no deberia
// necesitar cambios grandes, pero si el equipo agrega una cuarta seccion
// al bottom nav del admin, es aca donde hay que agregar el tab nuevo.
// ============================================================

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: AdminBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
