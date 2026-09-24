import 'package:flutter/material.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/widgets/primary_button.dart';

// ============================================================
// RESPONSABLE: Facundo Fornes
//
// TAREA:
// Pantalla de login del administrador.
//
// OBJETIVO:
// Mostrar un formulario visual de usuario/email y contraseña. Al
// presionar "Entrar", navegar SIEMPRE a Admin Dashboard
// (RouteNames.adminHome), sin validar credenciales todavia.
//
// IMPORTANTE:
// NO implementar autenticacion real. No hace falta validar el
// email/contraseña contra nada. Cualquier valor (incluso vacio) debe
// dejar entrar.
//
// DEBE UTILIZAR:
// - PrimaryButton
// - AppColors / AppTextStyles
//
// NO DEBE HACER:
// - Llamadas a un backend de autenticacion.
// - Guardar tokens ni sesiones.
//
// POSTERIORMENTE:
// Cuando exista autenticacion real, el boton "Entrar" va a validar
// contra el backend (por ejemplo con un `AuthService`, similar en
// espiritu a `ProductService`) y solo navegar si la respuesta es
// exitosa, mostrando un error visual si falla.
//
// PROMPT PARA IA:
//
// "Estoy trabajando en una app Flutter (Material 3) llamada Zapi.
// Tengo la pantalla lib/features/admin/login/admin_login_screen.dart
// (AdminLoginScreen, StatefulWidget) con un formulario simple (email y
// contraseña, con TextEditingController) y un boton 'Entrar'
// (PrimaryButton) que hoy navega directo a
// RouteNames.adminHome con Navigator.pushReplacementNamed sin validar
// nada. Quiero que le agregues validaciones basicas de FORMULARIO
// (campos no vacios, con Form + TextFormField + validator) para que se
// vea mas real, pero SIN conectar ninguna autenticacion de verdad: si
// pasa la validacion de formulario, debe seguir navegando igual que
// ahora a RouteNames.adminHome. No agregues llamadas HTTP ni guardes
// tokens."
// ============================================================

/// Pantalla de login del administrador. No valida credenciales reales.
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // NO hay autenticacion real: cualquier valor ingresado deja pasar.
    // Ver TAREA arriba para lo que falta hacer aca en el futuro.
    Navigator.of(context).pushReplacementNamed(RouteNames.adminHome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
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
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'ejemplo@correo.com',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Contraseña', style: AppTextStyles.bodyBold),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
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
    );
  }
}
