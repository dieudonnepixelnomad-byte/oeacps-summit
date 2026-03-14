import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:summitoeacp/data/smugmug_service.dart';
import 'package:summitoeacp/providers/language_provider.dart';
import 'package:summitoeacp/l10n/app_localizations.dart';
import '../widgets/app_image.dart';
import '../../models/media.dart';

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
          onTap: () =>
              context.push('/media/album/${album.id}', extra: album.title),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    /// PHOTO STACK EFFECT (arrière plan)
                    Positioned(
                      top: 6,
                      left: 6,
                      right: -6,
                      bottom: -6,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),

                    Positioned(
                      top: 3,
                      left: 3,
                      right: -3,
                      bottom: -3,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),

                    /// IMAGE PRINCIPALE
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          album.coverImageUrl.isNotEmpty
                              ? AppImage(
                                  album.coverImageUrl,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey.shade300,
                                  child: const Center(
                                    child: Icon(
                                      Icons.folder_open,
                                      color: Colors.green,
                                      size: 48,
                                    ),
                                  ),
                                ),

                          /// GRADIENT POUR LISIBILITE
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.center,
                                colors: [
                                  Colors.black54,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),

                          /// BADGE ALBUM
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.photo_library,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),

                          /// COMPTEUR PHOTOS
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.photo,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${album.imageCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              /// TITRE ALBUM
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

              /// DATE
              Text(
                album.dateLabel,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}