import 'package:flutter/material.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/widgets/primary_button.dart';

/// Pantalla de éxito luego de confirmar el pago (mock).
class ClientOrderConfirmationScreen extends StatelessWidget {
  const ClientOrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 52),
              ),
              const SizedBox(height: 24),
              const Text('¡Gracias por tu compra!', style: AppTextStyles.screenTitle),
              const SizedBox(height: 8),
              Text(
                'Tu pedido #${DateTime.now().millisecondsSinceEpoch % 10000} fue confirmado.',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Volver al inicio',
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                    RouteNames.clientCart,
                    (route) => false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
