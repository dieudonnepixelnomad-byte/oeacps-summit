import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:summitoeacp/data/wordpress_service.dart';
import 'package:summitoeacp/providers/language_provider.dart';
import 'package:summitoeacp/l10n/app_localizations.dart';
import '../widgets/app_image.dart';
import '../../models/speaker.dart';
import '../theme/app_theme.dart';

class SpeakersScreen extends StatefulWidget {
  const SpeakersScreen({super.key});

  @override
  State<SpeakersScreen> createState() => _SpeakersScreenState();
}

class _SpeakersScreenState extends State<SpeakersScreen> {
  List<Speaker>? _allSpeakers;
  List<Speaker>? _filteredSpeakers;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String? _lastLang;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterSpeakers);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = Provider.of<LanguageProvider>(context).currentLanguageCode;
    if (_lastLang != lang) {
      _lastLang = lang;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final lang = _lastLang ?? 'fr';
    final speakers = await context.read<WordpressService>().getSpeakers(
      lang: lang,
    );
    if (mounted) {
      setState(() {
        _allSpeakers = speakers;
        _filteredSpeakers = speakers;
        _isLoading = false;
      });
      _filterSpeakers(); // Re-apply filter if any
    }
  }

  void _filterSpeakers() {
    final query = _searchController.text.toLowerCase();
    if (_allSpeakers != null) {
      setState(() {
        _filteredSpeakers = _allSpeakers!.where((s) {
          return s.fullName.toLowerCase().contains(query) ||
              s.organization.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).currentLocale;
    final l10n = AppLocalizations(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('speakers_page_title')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.translate('search_speakers_hint'),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // "Featured" Section
                if (_searchController.text.isEmpty) ...[
                  Text(
                    l10n.translate('featured_speakers'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _allSpeakers!
                          .where((s) => s.isFeatured)
                          .length,
                      separatorBuilder: (ctx, i) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final speaker = _allSpeakers!
                            .where((s) => s.isFeatured)
                            .toList()[index];
                        return _buildFeaturedCard(speaker);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.translate('all_speakers'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                ],

                // List of all speakers
                ..._filteredSpeakers!.map(
                  (speaker) => _buildSpeakerRow(speaker),
                ),

                if (_filteredSpeakers!.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(child: Text(l10n.translate('no_speakers_found'))),
                  ),
              ],
            ),
    );
  }

  Widget _buildFeaturedCard(Speaker speaker) {
    return GestureDetector(
      onTap: () => context.push('/speakers/detail/${speaker.id}'),
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: AppImage(
                speaker.avatarUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                speaker.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                speaker.organization,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeakerRow(Speaker speaker) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipOval(
          child: AppImage(
            speaker.avatarUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          speaker.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              speaker.titleRole,
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 12,
              ),
            ),
            Text(speaker.organization),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: () => context.push('/speakers/detail/${speaker.id}'),
      ),
    );
  }
}
