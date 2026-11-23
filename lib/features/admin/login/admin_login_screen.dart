import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/widgets/primary_button.dart';
import 'package:zapi/state/auth_controller.dart';
import 'package:zapi/state/product_catalog.dart';

/// Pantalla de login del administrador.
///
/// Valida usuario y contraseña contra el backend (`POST /auth/login`, via
/// [AuthController]). Solo deja pasar a usuarios con rol ADMIN; ante un
/// error (credenciales incorrectas, sin conexion, rol EMPLOYEE) muestra el
/// mensaje debajo del formulario.
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthController>();
    final catalog = context.read<ProductCatalog>();
    final navigator = Navigator.of(context);

    final ok = await auth.login(_usernameController.text, _passwordController.text);
    if (!ok || !mounted) return;

    // Con la sesion iniciada el catalogo tambien carga los productos
    // ocultos y sin stock (`GET /products/all`).
    catalog.load();
    navigator.pushReplacementNamed(RouteNames.adminHome);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      extendBodyBehindAppBar: true,
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
                const Text('Usuario', style: AppTextStyles.bodyBold),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _usernameController,
                  enabled: !auth.isLoading,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'admin',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Ingresá tu usuario'
                      : null,
                ),
                const SizedBox(height: 20),
                const Text('Contraseña', style: AppTextStyles.bodyBold),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  enabled: !auth.isLoading,
                  obscureText: true,
                  onFieldSubmitted: (_) => _handleLogin(),
                  decoration: const InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Ingresá tu contraseña'
                      : null,
                ),
                const SizedBox(height: 32),
                if (auth.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  PrimaryButton(label: 'Entrar', onPressed: _handleLogin),
                if (auth.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      auth.errorMessage!,
                      style: AppTextStyles.caption.copyWith(color: AppColors.danger),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
