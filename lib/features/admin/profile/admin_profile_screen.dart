import 'package:flutter/material.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/widgets/app_header.dart';

/// Perfil / configuración del administrador logueado (datos mock, sin
/// autenticación real todavía, ver lib/features/admin/login).
class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Perfil', showBackButton: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.person, size: 44, color: AppColors.primary),
                  ),
                  SizedBox(height: 12),
                  Text('Administrador Zapi', style: AppTextStyles.sectionTitle),
                  Text('admin@zapi.com', style: AppTextStyles.caption),
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
              onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                RouteNames.adminLogin,
                (route) => false,
              ),
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
