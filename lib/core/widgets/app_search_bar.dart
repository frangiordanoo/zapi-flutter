import 'package:flutter/material.dart';
import 'package:zapi/app/theme/app_colors.dart';

/// Buscador reutilizable (usado en Admin > Productos y Admin > Stock,
/// pero cualquier pantalla lo puede usar).
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.onChanged,
    this.hintText = 'Buscar productos...',
  });

  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
      ),
    );
  }
}
