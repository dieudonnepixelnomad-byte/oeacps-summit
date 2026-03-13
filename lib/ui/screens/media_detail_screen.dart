import 'dart:developer' as developer show log;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:summitoeacp/data/smugmug_service.dart';
import '../../models/media.dart';
import '../widgets/app_image.dart';

class MediaDetailScreen extends StatelessWidget {
  final String mediaId;

  const MediaDetailScreen({super.key, required this.mediaId});

  @override
  Widget build(BuildContext context) {
    final service = context.read<SmugMugService>();
    developer.log('MediaDetailScreen: Loading mediaId=$mediaId');

    return FutureBuilder<MediaItem?>(
      // Utilisation de SmugMugService
      future: service.getMediaById(mediaId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          developer.log(
            'MediaDetailScreen error: ${snapshot.error}',
            error: snapshot.error,
          );
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                "Erreur lors du chargement du média",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        final item = snapshot.data;
        if (item == null || item.id.isEmpty) {
          developer.log('MediaDetailScreen: Item is null or empty');
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                "Média introuvable",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        developer.log('MediaDetailScreen: Loaded item ${item.title}');

        // ✅ Toujours thumbnail (plus stable)
        final String stableImageUrl = item.coverImageUrl.isNotEmpty
            ? item.coverImageUrl
            : item.mediaUrl;

        return Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  final box = context.findRenderObject() as RenderBox?;
                  final text = [
                    if (item.title.isNotEmpty) item.title,
                    // On partage la source (mediaUrl) si dispo, sinon la cover
                    (item.mediaUrl.isNotEmpty
                        ? item.mediaUrl
                        : item.coverImageUrl),
                  ].where((e) => e.trim().isNotEmpty).join('\n');

                  if (text.trim().isEmpty) return;

                  SharePlus.instance.share(
                    ShareParams(
                      text: text,
                      sharePositionOrigin: box != null
                          ? (box.localToGlobal(Offset.zero) & box.size)
                          : null,
                    ),
                  );
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              Center(
                child: item.type == MediaType.photo
                    ? InteractiveViewer(
                        child: AppImage(stableImageUrl, fit: BoxFit.contain),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ✅ Vidéo: on affiche quand même la thumbnail stable (coverImageUrl)
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              AppImage(stableImageUrl, fit: BoxFit.contain),
                              const Icon(
                                Icons.play_circle_fill,
                                color: Colors.white,
                                size: 64,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Lecteur vidéo à intégrer",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
              ),

              // ✅ Footer gradient + infos
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.85),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title.isNotEmpty ? item.title : "Média",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.timeLabel,
                              style: const TextStyle(color: Colors.white70),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.locationLabel,
                              style: const TextStyle(color: Colors.white70),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
