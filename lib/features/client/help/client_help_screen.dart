import 'package:flutter/material.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/widgets/app_header.dart';

/// Preguntas frecuentes del kiosco (contenido estático, sin backend).
class ClientHelpScreen extends StatelessWidget {
  const ClientHelpScreen({super.key});

  static const _faqs = [
    (
      question: '¿Qué hago si el código de barras no se lee?',
      answer: 'Podés buscar el producto manualmente desde "Ver lista" y agregarlo con un toque.',
    ),
    (
      question: '¿Puedo sacar un producto del carrito?',
      answer: 'Sí, desde el carrito o el scanner podés usar el ícono de tacho para eliminarlo, o los botones +/- para ajustar la cantidad.',
    ),
    (
      question: '¿Cómo pago mi compra?',
      answer: 'Cuando tengas productos en el carrito, tocá "Pagar" desde la pantalla de escaneo para ir al resumen de compra.',
    ),
    (
      question: '¿Necesito una cuenta para comprar?',
      answer: 'No, el kiosco funciona sin login. Solo el personal del local necesita iniciar sesión para administrar productos.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Ayuda', showBackButton: true),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: _faqs.length,
          separatorBuilder: (_, __) => const Divider(height: 28, color: AppColors.border),
          itemBuilder: (context, index) {
            final faq = _faqs[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(faq.question, style: AppTextStyles.sectionTitle),
                const SizedBox(height: 6),
                Text(faq.answer, style: AppTextStyles.body),
              ],
            );
          },
        ),
      ),
    );
  }
}
