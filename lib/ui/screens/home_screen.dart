import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:summitoeacp/providers/language_provider.dart';
import 'package:summitoeacp/l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _lastLang;
  final Uri _eventProgramPdfUrl = Uri.parse(
    "https://summitoacps.com/wp-content/uploads/2026/02/Agenda-11eme-Sommet-oeacp-2026.pdf",
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = Provider.of<LanguageProvider>(context).currentLanguageCode;
    if (_lastLang != lang) {
      _lastLang = lang;
    }
  }

  Future<void> _openEventProgramPdf() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final lang = Provider.of<LanguageProvider>(
      context,
      listen: false,
    ).currentLocale;
    final l10n = AppLocalizations(lang);

    try {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l10n.translate('downloading_program'))),
      );

      // Récupération du dossier
      Directory? dir;
      if (Platform.isAndroid) {
        dir = await getDownloadsDirectory();
      }
      dir ??= await getApplicationDocumentsDirectory();

      final filename = "Agenda-11eme-Sommet-oeacp-2026.pdf";
      final file = File('${dir.path}/$filename');

      // Téléchargement
      final response = await http.get(_eventProgramPdfUrl);

      if (response.statusCode == 200) {
        // Écriture du fichier
        await file.writeAsBytes(response.bodyBytes);

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              "${l10n.translate('download_completed')} ${dir.path}",
            ),
          ),
        );

        // Ouverture du fichier
        final result = await OpenFilex.open(file.path);
        if (result.type != ResultType.done) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                "${l10n.translate('cannot_open_file')}: ${result.message}",
              ),
            ),
          );
        }
      } else {
        throw Exception(
          '${l10n.translate('http_error')} ${response.statusCode}',
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("${l10n.translate('download_error')} ($e)")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations(languageProvider.currentLocale);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.translate('home_title'),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          /* IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () => context.push('/notifications'),
          ), */
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: languageProvider.currentLanguageCode,
                icon: const Icon(Icons.language, color: Colors.black),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    languageProvider.setLanguage(newValue);
                  }
                },
                items: const [
                  DropdownMenuItem(value: 'fr', child: Text('FR')),
                  DropdownMenuItem(value: 'en', child: Text('EN')),
                  DropdownMenuItem(value: 'es', child: Text('ES')),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/bg_header.jpeg',
                      width: double.infinity,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF006A4E).withValues(alpha: 0.3),
                            const Color(0xFF006A4E).withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            l10n.translate('summit_subtitle'),
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.translate('home_main_title'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.translate('home_main_subtitle'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Accreditation Card (Floating overlap)
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => {_openEventProgramPdf()},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: Colors.black, // Dark text on Gold
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.translate('download_full_program'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Quick Menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate('quick_menu'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuTile(
                    context,
                    icon: Icons.qr_code,
                    title: l10n.translate('accreditations_tab'),
                    subtitle: l10n.translate('accreditations_subtitle'),
                    color: Colors.green.shade50,
                    iconColor: Colors.green,
                    onTap: () => context.go('/accreditation'),
                  ),
                  _buildMenuTile(
                    context,
                    icon: Icons.info_outline,
                    title: l10n.translate('menu_guide'),
                    subtitle: l10n.translate('menu_guide_subtitle'),
                    color: Colors.green.shade50,
                    iconColor: Colors.green,
                    onTap: () => context.go('/info'),
                  ),
                  _buildMenuTile(
                    context,
                    icon: Icons.event,
                    title: l10n.translate('menu_events'),
                    subtitle: l10n.translate('menu_events_subtitle'),
                    color: Colors.green.shade50,
                    iconColor: Colors.green,
                    onTap: () => context.go('/events'),
                  ),
                  _buildMenuTile(
                    context,
                    icon: Icons.newspaper,
                    title: l10n.translate('menu_press_room'),
                    subtitle: l10n.translate('menu_press_room_subtitle'),
                    color: Colors.green.shade50,
                    iconColor: Colors.green,
                    onTap: () => context.push('/press_room'),
                  ),
                  _buildMenuTile(
                    context,
                    icon: Icons.question_answer,
                    title: l10n.translate('menu_about'),
                    subtitle: l10n.translate('menu_about_subtitle'),
                    color: Colors.green.shade50,
                    iconColor: Colors.green,
                    onTap: () => context.push('/about'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
