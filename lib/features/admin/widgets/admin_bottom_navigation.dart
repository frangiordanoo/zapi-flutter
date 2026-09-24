import 'package:flutter/material.dart';

/// Barra de navegacion inferior del administrador.
///
/// Es un componente "tonto": solo muestra el indice seleccionado y
/// avisa cuando el usuario toca otro item. Quien decide que pantalla
/// mostrar para cada indice es [AdminShell]
/// (lib/features/admin/admin_shell.dart). No duplicar este navbar en
/// cada pantalla de admin.
class AdminBottomNavigation extends StatelessWidget {
  const AdminBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: 'Estadísticas',
        ),
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2),
          label: 'Productos',
        ),
        NavigationDestination(
          icon: Icon(Icons.list_alt_outlined),
          selectedIcon: Icon(Icons.list_alt),
          label: 'Stock',
        ),
      ],
    );
  }
}
