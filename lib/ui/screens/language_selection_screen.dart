import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:summitoeacp/providers/language_provider.dart';
import 'package:summitoeacp/ui/theme/app_theme.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),
              // Logo
              Center(
                child: Image.asset(
                  'assets/images/logo_app.png',
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              // Titre
              const Text(
                'Bienvenue / Welcome / Bienvenida',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Veuillez choisir votre langue\nPlease choose your language\nElija su idioma',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Spacer(flex: 1),
              // Boutons de langue
              _buildLanguageButton(
                context,
                label: 'Français',
                flag: '🇫🇷',
                code: 'fr',
              ),
              const SizedBox(height: 16),
              _buildLanguageButton(
                context,
                label: 'English',
                flag: '🇬🇧',
                code: 'en',
              ),
              const SizedBox(height: 16),
              _buildLanguageButton(
                context,
                label: 'Español',
                flag: '🇪🇸',
                code: 'es',
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(
    BuildContext context, {
    required String label,
    required String flag,
    required String code,
  }) {
    return InkWell(
      onTap: () {
        context.read<LanguageProvider>().setLanguage(code);
        context.go('/');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 24),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
