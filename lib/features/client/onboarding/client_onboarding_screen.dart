import 'package:flutter/material.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/widgets/app_header.dart';
import 'package:zapi/core/widgets/primary_button.dart';
import 'package:zapi/core/widgets/secondary_button.dart';

/// Pantalla de introducción / "cómo funciona" el kiosco de Zapi.
///
/// Se accede desde un ícono en el header del carrito (no se muestra
/// automáticamente en cada apertura, para no interrumpir el uso normal
/// del kiosco).
class ClientOnboardingScreen extends StatelessWidget {
  const ClientOnboardingScreen({super.key});

  static const _steps = [
    (
      icon: Icons.qr_code_scanner,
      title: 'Escaneá tus productos',
      description: 'Usá la cámara para leer el código de barras de cada producto y agregarlo a tu carrito.',
    ),
    (
      icon: Icons.list_alt,
      title: '¿No tenés el producto a mano?',
      description: 'Buscalo en "Ver lista" y agregalo con un toque, sin necesidad de escanear.',
    ),
    (
      icon: Icons.shopping_cart_checkout,
      title: 'Revisá tu carrito y pagá',
      description: 'Ajustá cantidades, sacá lo que no quieras y confirmá tu compra desde el carrito.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: '¿Cómo funciona?', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: _steps.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final step = _steps[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(step.icon, color: AppColors.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(step.title, style: AppTextStyles.sectionTitle),
                              const SizedBox(height: 4),
                              Text(step.description, style: AppTextStyles.body),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'Preguntas frecuentes',
                icon: Icons.help_outline,
                onPressed: () => Navigator.pushNamed(context, RouteNames.clientHelp),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Entendido',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
