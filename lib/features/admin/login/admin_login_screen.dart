import 'package:flutter/material.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/widgets/primary_button.dart';

/// Pantalla de login del administrador.
///
/// No valida credenciales reales: solo valida que el formulario este
/// completo. Cuando exista un backend de autenticacion, `_handleLogin`
/// deberia validar contra el mismo (por ejemplo con un `AuthService`,
/// siguiendo el mismo patron que `ProductService`) y solo navegar si la
/// respuesta es exitosa.
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // NO hay autenticacion real: alcanza con que el formulario este
    // completo para dejar pasar.
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pushReplacementNamed(RouteNames.adminHome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Iniciar Sesión', style: AppTextStyles.screenTitle),
                const SizedBox(height: 4),
                const Text(
                  'Ingresá las credenciales de Zapi',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 32),
                const Text('Correo Electrónico', style: AppTextStyles.bodyBold),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'ejemplo@correo.com',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Ingresá tu correo'
                      : null,
                ),
                const SizedBox(height: 20),
                const Text('Contraseña', style: AppTextStyles.bodyBold),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Ingresá tu contraseña'
                      : null,
                ),
                const SizedBox(height: 32),
                PrimaryButton(label: 'Entrar', onPressed: _handleLogin),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'La autenticación real se integrará más adelante.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
