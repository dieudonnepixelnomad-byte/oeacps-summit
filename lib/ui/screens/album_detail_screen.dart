import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:summitoeacp/data/smugmug_service.dart';
import 'package:summitoeacp/providers/language_provider.dart';
import 'package:summitoeacp/l10n/app_localizations.dart';
import '../widgets/app_image.dart';
import '../../models/media.dart';

class AlbumDetailScreen extends StatefulWidget {
  final String albumId;
  final String? albumTitle;

  const AlbumDetailScreen({super.key, required this.albumId, this.albumTitle});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  List<MediaItem>? _mediaList;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    developer.log('AlbumDetailScreen: _loadData for album ${widget.albumId}');
    try {
      final media = await context.read<SmugMugService>().getAlbumImages(
        widget.albumId,
        widget.albumTitle ?? 'Album',
      );

      if (mounted) {
        setState(() {
          _mediaList = media;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      developer.log(
        'AlbumDetailScreen: Error loading data',
        error: e,
        stackTrace: stack,
      );
      if (mounted) {
        setState(() {
          _mediaList = [];
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
      appBar: AppBar(
        title: Text(widget.albumTitle ?? l10n.translate('media_page_title')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mediaList == null || _mediaList!.isEmpty
          ? Center(child: Text(l10n.translate('no_media_found')))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _mediaList!.length,
              itemBuilder: (context, index) {
                final item = _mediaList![index];
                return InkWell(
                  onTap: () => context.push('/media/detail/${item.id}'),
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
                              child: AppImage(
                                item.coverImageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                            if (item.type == MediaType.video)
                              const Center(
                                child: Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // const SizedBox(height: 8),
                      // Text(
                      //   item.title,
                      //   maxLines: 2,
                      //   overflow: TextOverflow.ellipsis,
                      //   style: const TextStyle(
                      //     fontWeight: FontWeight.bold,
                      //     fontSize: 13,
                      //   ),
                      // ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
