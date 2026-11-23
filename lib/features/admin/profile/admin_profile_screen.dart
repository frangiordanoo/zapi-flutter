import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/features/admin/stats/stats_controller.dart';
import 'package:zapi/state/auth_controller.dart';
import 'package:zapi/state/product_catalog.dart';
import 'package:zapi/state/sales_history_controller.dart';

/// Perfil del administrador logueado (usuario real de `/auth/login`) y
/// cierre de sesion.
class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  void _logout(BuildContext context) {
    context.read<AuthController>().logout();
    context.read<StatsController>().clear();
    context.read<SalesHistoryController>().clear();
    // Sin sesion el catalogo vuelve a ser solo el publico.
    context.read<ProductCatalog>().load();
    Navigator.of(context).pushNamedAndRemoveUntil(
      RouteNames.clientCart,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;

    return Scaffold(
      appBar: const AppHeader(title: 'Perfil', showBackButton: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.person, size: 44, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(user?.username ?? 'Administrador Zapi',
                      style: AppTextStyles.sectionTitle),
                  const Text('Administrador', style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const _MenuTile(icon: Icons.lock_outline, label: 'Cambiar contraseña'),
            const _MenuTile(icon: Icons.notifications_outlined, label: 'Preferencias de notificación'),
            _MenuTile(
              icon: Icons.logout,
              label: 'Cerrar sesión',
              color: AppColors.danger,
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, this.color, this.onTap});

  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(label, style: AppTextStyles.body.copyWith(color: color)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap ??
          () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Disponible próximamente')),
              ),
    );
  }
}
