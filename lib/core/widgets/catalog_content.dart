import 'package:flutter/material.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/widgets/empty_state.dart';
import 'package:zapi/core/widgets/error_state.dart';
import 'package:zapi/state/product_catalog.dart';

/// Resuelve los estados del catalogo para cualquier pantalla con listado:
/// cargando, error sin datos, catalogo vacio, o contenido (con un aviso si
/// la ultima recarga fallo y se estan mostrando datos anteriores).
///
/// Ocupa el espacio disponible: usarlo dentro de un `Expanded`.
class CatalogContent extends StatelessWidget {
  const CatalogContent({super.key, required this.catalog, required this.child});

  final ProductCatalog catalog;

  /// El contenido normal (por ejemplo la lista de productos).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final hasData = catalog.products.isNotEmpty;

    if (!hasData && catalog.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!hasData && catalog.errorMessage != null) {
      return ErrorState(message: catalog.errorMessage!, onRetry: catalog.load);
    }
    if (!hasData) {
      return const EmptyState(
        icon: Icons.inventory_2_outlined,
        message: 'Todavía no hay productos cargados.',
      );
    }

    return Column(
      children: [
        if (catalog.errorMessage != null)
          _StaleBanner(onRetry: catalog.load),
        Expanded(child: child),
      ],
    );
  }
}

class _StaleBanner extends StatelessWidget {
  const _StaleBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.warning),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'No se pudo actualizar. Se muestran datos anteriores.',
              style: AppTextStyles.caption,
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
