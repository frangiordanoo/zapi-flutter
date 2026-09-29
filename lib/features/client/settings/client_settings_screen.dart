import 'package:flutter/material.dart';
import 'package:zapi/app/router/route_names.dart';
import 'package:zapi/app/theme/app_colors.dart';
import 'package:zapi/app/theme/app_text_styles.dart';
import 'package:zapi/core/widgets/app_header.dart';

/// Configuración del kiosco visible para el cliente (idioma, accesibilidad,
/// ayuda). Todo es visual/mock: no persiste ningún cambio todavía.
class ClientSettingsScreen extends StatefulWidget {
  const ClientSettingsScreen({super.key});

  @override
  State<ClientSettingsScreen> createState() => _ClientSettingsScreenState();
}

class _ClientSettingsScreenState extends State<ClientSettingsScreen> {
  String _language = 'Español';
  bool _largeText = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Configuración', showBackButton: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Idioma', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 8),
            _OptionTile(
              icon: Icons.language,
              label: _language,
              onTap: () => setState(() {
                _language = _language == 'Español' ? 'English' : 'Español';
              }),
            ),
            const SizedBox(height: 20),
            const Text('Accesibilidad', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _largeText,
              onChanged: (value) => setState(() => _largeText = value),
              title: const Text('Texto grande', style: AppTextStyles.body),
              activeThumbColor: AppColors.primary,
            ),
            const SizedBox(height: 20),
            const Text('Soporte', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 8),
            _OptionTile(
              icon: Icons.info_outline,
              label: '¿Cómo funciona el kiosco?',
              onTap: () => Navigator.pushNamed(context, RouteNames.clientOnboarding),
            ),
            const SizedBox(height: 12),
            _OptionTile(
              icon: Icons.help_outline,
              label: 'Preguntas frecuentes',
              onTap: () => Navigator.pushNamed(context, RouteNames.clientHelp),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.body)),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
