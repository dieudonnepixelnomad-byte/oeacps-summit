import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:summitoeacp/data/wordpress_service.dart';
import 'package:summitoeacp/providers/language_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/app_image.dart';
import 'package:summitoeacp/l10n/app_localizations.dart';
import '../../models/speaker.dart';
import '../theme/app_theme.dart';

class SpeakerDetailScreen extends StatefulWidget {
  final String speakerId;

  const SpeakerDetailScreen({super.key, required this.speakerId});

  @override
  State<SpeakerDetailScreen> createState() => _SpeakerDetailScreenState();
}

class _SpeakerDetailScreenState extends State<SpeakerDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Speaker>>(
      future: context.read<WordpressService>().getSpeakers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final speaker = snapshot.data!.firstWhere(
          (s) => s.id == widget.speakerId,
          orElse: () => Speaker(
            id: 'unknown',
            fullName: 'Unknown',
            titleRole: '',
            organization: '',
            countryCode: '',
            avatarUrl: '',
            bio: '',
            contactEmail: '',
            websiteUrl: '',
          ),
        );

        final lang = Provider.of<LanguageProvider>(context).currentLocale;
        final l10n = AppLocalizations(lang);

        if (speaker.id == 'unknown') {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.translate('error_not_found'))),
            body: Center(child: Text(l10n.translate('speaker_not_found'))),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.translate('speaker_detail_title')),
            actions: [
              IconButton(
                icon: Icon(
                  speaker.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: speaker.isBookmarked ? AppTheme.primaryColor : null,
                ),
                onPressed: () {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.translate('favorites_updated')),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                ClipOval(
                  child: AppImage(
                    speaker.avatarUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  speaker.fullName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  speaker.titleRole,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  speaker.organization,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (speaker.contactEmail.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.email_outlined),
                        color: AppTheme.primaryColor,
                        onPressed: () {
                          _launchUrl('mailto:${speaker.contactEmail}');
                        },
                      ),
                    if (speaker.websiteUrl.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.language),
                        color: AppTheme.primaryColor,
                        onPressed: () {
                          _launchUrl(speaker.websiteUrl);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.translate('biography_label'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  speaker.bio,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }
}
