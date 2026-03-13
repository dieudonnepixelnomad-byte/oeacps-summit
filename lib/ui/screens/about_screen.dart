import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:summitoeacp/data/about_data.dart';
import 'package:summitoeacp/providers/language_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langCode = Provider.of<LanguageProvider>(context).currentLanguageCode;
    final data = AboutData.data[langCode] ?? AboutData.data['fr']!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                data.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  const AppImage(
                    'assets/images/bg_header.jpeg',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. App Description
                  _buildSectionTitle(data.appDescriptionTitle),
                  const SizedBox(height: 8),
                  Text(
                    data.appDescriptionContent,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // 2. Event Description
                  _buildSectionTitle(data.eventTitle),
                  const SizedBox(height: 8),
                  Text(
                    data.eventContent,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // 3. Organization (OACPS)
                  _buildSectionTitle(data.oacpsTitle),
                  const SizedBox(height: 8),
                  Text(
                    data.oacpsContent,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // 4. Features
                  _buildSectionTitle(data.featuresTitle),
                  const SizedBox(height: 8),
                  ...data.features.map((f) => _buildFeatureItem(f)),
                  const SizedBox(height: 24),

                  // 5. Organization Info
                  _buildSectionTitle(data.organizationTitle),
                  const SizedBox(height: 8),
                  Text(
                    data.organizationContent,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // 6. Contact
                  _buildSectionTitle(data.contactTitle),
                  const SizedBox(height: 8),
                  Text(
                    data.contactContent,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // 7. Legal
                  _buildSectionTitle(data.legalTitle),
                  const SizedBox(height: 8),
                  Text(
                    data.legalContent,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 8. Version
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(
                          data.versionContent,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
            letterSpacing: 1.1,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4, bottom: 8),
          height: 3,
          width: 40,
          color: AppTheme.accentColor,
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
