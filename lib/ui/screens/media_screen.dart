import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:summitoeacp/data/smugmug_service.dart';
import 'package:summitoeacp/providers/language_provider.dart';
import 'package:summitoeacp/l10n/app_localizations.dart';
import '../widgets/app_image.dart';
import '../../models/media.dart';
import '../theme/app_theme.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  List<Album>? _allAlbums;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    developer.log('MediaScreen: _loadData (Albums) started');
    try {
      final albums = await context.read<SmugMugService>().getAlbums();
      developer.log(
        'MediaScreen: Received ${albums.length} albums from SmugMugService',
      );
      if (mounted) {
        setState(() {
          _allAlbums = albums;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      developer.log(
        'MediaScreen: Error loading albums',
        error: e,
        stackTrace: stack,
      );
      if (mounted) {
        setState(() {
          _allAlbums = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).currentLocale;
    final l10n = AppLocalizations(lang);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('media_page_title'))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildAlbumGrid(l10n),
    );
  }

  Widget _buildAlbumGrid(AppLocalizations l10n) {
    // Plus de filtrage : on affiche tous les albums récupérés
    final displayList = _allAlbums ?? [];

    if (displayList.isEmpty) {
      return Center(child: Text(l10n.translate('no_media_found')));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        final album = displayList[index];
        return InkWell(
          // Navigation vers le détail de l'album
          onTap: () =>
              context.push('/media/album/${album.id}', extra: album.title),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: album.coverImageUrl.isNotEmpty
                          ? AppImage(album.coverImageUrl, fit: BoxFit.cover)
                          : Container(
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Icon(
                                  Icons.photo_album,
                                  color: Colors.grey,
                                  size: 48,
                                ),
                              ),
                            ),
                    ),
                    // Indicateur album
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${album.imageCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                album.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                album.dateLabel,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }
}
