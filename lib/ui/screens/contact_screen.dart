import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:summitoeacp/providers/language_provider.dart';
import 'package:summitoeacp/l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).currentLocale;
    final l10n = AppLocalizations(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('contact_page_title')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            title: l10n.translate('contact_secretariat_title'),
            icon: Icons.business,
            children: [
              _buildActionRow(
                icon: Icons.email,
                label: 'contact@oeacp-summit.org',
                onTap: () => _launchUrl('mailto:contact@oeacp-summit.org'),
              ),
              _buildActionRow(
                icon: Icons.phone,
                label: '+33 1 23 45 67 89',
                onTap: () => _launchUrl('tel:+33123456789'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            title: l10n.translate('contact_technical_title'),
            icon: Icons.computer,
            children: [
              _buildActionRow(
                icon: Icons.chat,
                label: l10n.translate('contact_chat_label'),
                onTap: () {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.translate('chat_simulation_msg'))));
                },
                color: Colors.green,
              ),
              _buildActionRow(
                icon: Icons.help_outline,
                label: 'support@oeacp-summit.org',
                onTap: () => _launchUrl('mailto:support@oeacp-summit.org'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            title: l10n.translate('contact_emergency_title'),
            icon: Icons.local_hospital,
            color: Colors.red.shade50,
            titleColor: Colors.red,
            children: [
              _buildActionRow(
                icon: Icons.call,
                label: l10n.translate('contact_emergency_number'),
                onTap: () => _launchUrl('tel:112'),
                color: Colors.red,
                isBold: true,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                child: Text(
                  l10n.translate('contact_medical_team_msg'),
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            l10n.translate('contact_quick_request_title'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: l10n.translate('contact_message_hint'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.translate('contact_message_sent'))));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(l10n.translate('contact_send_btn')),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color? color,
    Color? titleColor,
  }) {
    return Card(
      color: color ?? Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: titleColor ?? AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: titleColor ?? AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
    bool isBold = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.grey[700], size: 20),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: color ?? AppTheme.textPrimary,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }
}
