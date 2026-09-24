import 'package:flutter/material.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/utils/formatters.dart';
import 'package:zapi/models/product.dart';

/// Fila reutilizable para mostrar un producto en una lista.
///
/// Se usa en Client > Product List (con un boton "Añadir" como
/// `trailing`) y en Admin > Products / Admin > Stock (con botones de
/// editar/borrar, o con el stock actual, como `trailing`). El
/// contenido de la derecha queda a cargo de quien use el widget para no
/// tener que crear una fila distinta por pantalla.
class ProductItem extends StatelessWidget {
  const ProductItem({
    super.key,
    required this.product,
    required this.trailing,
    this.subtitle,
  });

  final Product product;
  final Widget trailing;

  /// Texto secundario opcional debajo del precio (ej: "Stock: 12").
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: AppTextStyles.bodyBold),
                const SizedBox(height: 4),
                Text(Formatters.currency(product.price),
                    style: AppTextStyles.price),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style: AppTextStyles.caption.copyWith(
                        color: product.stock == 0
                            ? AppColors.danger
                            : AppColors.textSecondary,
                      )),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
