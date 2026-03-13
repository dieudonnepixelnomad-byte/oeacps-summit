import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/media.dart';

class SmugMugService {
  final String _apiKey = kSmugmugApiKey;
  final String _baseUrl = kSmugmugApiUrl;
  final String _user = kSmugmugUser;

  Map<String, String> get _headers => {'Accept': 'application/json'};

  /// Récupère les albums de l'utilisateur
  Future<List<Album>> getAlbums() async {
    final List<Album> allAlbums = [];

    String? nextUrl =
        '$_baseUrl/user/$_user!albums'
        '?APIKey=$_apiKey'
        '&SortDirection=Descending'
        '&SortMethod=DateAdded'
        '&count=50'
        '&start=1'
        '&_expand=HighlightImage.ImageSizeDetails'
        '&_expandmethod=inline';

    while (nextUrl != null) {
      developer.log('Request URL: $nextUrl', name: 'SmugMugService');

      final res = await http.get(Uri.parse(nextUrl), headers: _headers);
      if (res.statusCode != 200) {
        developer.log(
          'Error: ${res.statusCode} - ${res.body}',
          name: 'SmugMugService',
        );
        break;
      }

      final data = jsonDecode(res.body);

      final List<dynamic> albumsData =
          (data['Response']?['Album'] as List?) ?? const [];
      for (final albumJson in albumsData) {
        final String albumKey = (albumJson['AlbumKey'] ?? '').toString();
        final String title = (albumJson['Title'] ?? 'Album').toString();
        final int imageCount = (albumJson['ImageCount'] ?? 0) as int;
        final String urlKey = (albumJson['UrlName'] ?? '').toString();

        final String dateStr =
            (albumJson['LastUpdated'] ?? albumJson['DateAdded'] ?? '')
                .toString();
        final String dateLabel = dateStr.length >= 10
            ? dateStr.substring(0, 10)
            : '';

        // ✅ HighlightImage inline (si disponible)
        String coverUrl = '';
        final highlight = albumJson['HighlightImage'];
        if (highlight != null) {
          // Doc-first: ImageSizeDetails
          final sizeDetails = highlight['ImageSizeDetails'];
          // Selon les réponses, ça peut être un tableau ou une map.
          // On gère les 2 sans planter.
          if (sizeDetails is Map) {
            coverUrl =
                (sizeDetails['LargestImageUrl'] ??
                        sizeDetails['X2LargeImageUrl'] ??
                        sizeDetails['XLargeImageUrl'] ??
                        sizeDetails['LargeImageUrl'] ??
                        sizeDetails['MediumImageUrl'] ??
                        sizeDetails['SmallImageUrl'] ??
                        sizeDetails['ThumbImageUrl'] ??
                        '')
                    .toString();
          }
        }

        // fallback simple : parfois AlbumImage a ThumbnailUrl, parfois pas.
        if (coverUrl.isEmpty && albumJson['ThumbnailUrl'] != null) {
          coverUrl = albumJson['ThumbnailUrl'].toString();
        }

        allAlbums.add(
          Album(
            id: albumKey,
            title: title,
            coverImageUrl: coverUrl,
            dateLabel: dateLabel,
            imageCount: imageCount,
            urlKey: urlKey,
          ),
        );
      }

      // ✅ Pagination SmugMug: Response.Pages.NextPage
      nextUrl = data['Response']?['Pages']?['NextPage'];
      if (nextUrl != null && !nextUrl.toString().startsWith('http')) {
        // NextPage est souvent une URI /api/v2/...
        nextUrl = '$_baseUrl${nextUrl.toString().replaceFirst('/api/v2', '')}';
        // ⚠️ selon ton _baseUrl (s'il contient déjà /api/v2), adapte cette concat.
      }
    }

    developer.log(
      'Total albums fetched: ${allAlbums.length}',
      name: 'SmugMugService',
    );
    return allAlbums;
  }

  /// Récupère les images d'un album spécifique
  Future<List<MediaItem>> getAlbumImages(
    String albumKey,
    String albumTitle,
  ) async {
    // Reuse internal logic
    return _getAlbumImages(albumKey, albumTitle);
  }

  // Deprecated: used for compatibility until full migration
  Future<List<MediaItem>> getRecentMedia({int limit = 20}) async {
    // ... Old logic or redirect to getAlbums + fetch images ...
    // Pour l'instant on garde l'ancienne logique si besoin, mais on va changer MediaScreen
    // Donc on peut commenter ou laisser tel quel pour ne pas casser si on revert.
    // On va laisser l'ancienne implémentation dessous pour référence ou fallback
    return [];
  }

  /// Internal: Récupère les images d'un album spécifique
  Future<List<MediaItem>> _getAlbumImages(
    String albumKey,
    String albumTitle,
  ) async {
    // Endpoint: /album/{key}!images
    final url =
        '$_baseUrl/album/$albumKey!images?APIKey=$_apiKey&count=30&SortDirection=Descending&SortMethod=DateUploaded&_expand=ImageSizes';

    try {
      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode != 200) {
        developer.log(
          'Error fetching album images ($albumKey): ${response.statusCode}',
          name: 'SmugMugService',
        );
        return [];
      }

      final data = jsonDecode(response.body);
      final List<dynamic> images = data['Response']['AlbumImage'] ?? [];

      developer.log(
        'Found ${images.length} images in album $albumTitle',
        name: 'SmugMugService',
      );

      return images.map((img) => _mapToMediaItem(img, albumTitle)).toList();
    } catch (e) {
      developer.log(
        'Exception fetching album images: $e',
        name: 'SmugMugService',
      );
      return [];
    }
  }

  /// Récupère un média spécifique par ID (ImageKey)
  /// Note: SmugMug utilise ImageKey, mais notre app utilise ID.
  /// On va supposer que l'ID passé est l'ImageKey.
  Future<MediaItem?> getMediaById(String imageKey) async {
    // Endpoint: /image/{key}
    // Note: L'endpoint réel est /image/{ImageKey}
    final url = '$_baseUrl/image/$imageKey?APIKey=$_apiKey&_expand=ImageSizes';

    try {
      // developer.log('Fetching media detail: $url', name: 'SmugMugService');
      final response = await http.get(Uri.parse(url), headers: _headers);

      // developer.log(
      //   'Media detail response status: ${response.statusCode}',
      //   name: 'SmugMugService',
      // );

      if (response.statusCode != 200) {
        developer.log(
          'Error fetching media detail: ${response.body}',
          name: 'SmugMugService',
        );
        return null;
      }

      final data = jsonDecode(response.body);
      final img = data['Response']['Image'];

      // Si ImageSizes est manquant, on tente de le récupérer via l'endpoint dédié
      if (img['ImageSizes'] == null) {
        developer.log(
          'ImageSizes missing in detail, fetching explicitly...',
          name: 'SmugMugService',
        );
        try {
          final sizesUrl = '$_baseUrl/image/$imageKey!sizes?APIKey=$_apiKey';
          final sizesResponse = await http.get(
            Uri.parse(sizesUrl),
            headers: _headers,
          );
          if (sizesResponse.statusCode == 200) {
            final sizesData = jsonDecode(sizesResponse.body);
            // La réponse contient directement l'objet ImageSizes dans Response -> ImageSizes
            if (sizesData['Response'] != null &&
                sizesData['Response']['ImageSizes'] != null) {
              img['ImageSizes'] = sizesData['Response']['ImageSizes'];
              developer.log(
                'ImageSizes fetched successfully',
                name: 'SmugMugService',
              );
            }
          }
        } catch (e) {
          developer.log(
            'Error fetching extra sizes: $e',
            name: 'SmugMugService',
          );
        }
      }

      // On n'a pas le titre de l'album ici facilement sans autre appel, on met un défaut
      return _mapToMediaItem(img, 'SmugMug');
    } catch (e) {
      developer.log(
        'Exception fetching media detail: $e',
        name: 'SmugMugService',
      );
      return null;
    }
  }

  MediaItem _mapToMediaItem(Map<String, dynamic> json, String albumTitle) {
    // Debug log for structure
    // if (json['ImageSizes'] == null) {
    //   developer.log(
    //     'ImageSizes missing for image ${json['ImageKey']}. Keys: ${json.keys.toList()}',
    //     name: 'SmugMugService',
    //   );
    //   if (json.containsKey('Uris')) {
    //      developer.log('Uris: ${json['Uris']}', name: 'SmugMugService');
    //   }
    // } else {
    //    // Log success once to verify structure
    //    // developer.log('ImageSizes found: ${json['ImageSizes'].keys}', name: 'SmugMugService');
    // }

    final sizes = json['ImageSizes'] ?? {};
    final String thumbnailUrl = json['ThumbnailUrl'] ?? '';

    // Choix de la meilleure qualité pour l'affichage detail
    final mediaUrl =
        sizes['LargeImageUrl'] ??
        sizes['XLargeImageUrl'] ??
        sizes['OriginalImageUrl'] ??
        // Fallback sur ThumbnailUrl si aucune taille n'est dispo (mieux que rien)
        thumbnailUrl;

    // Choix de la cover
    final coverUrl =
        sizes['MediumImageUrl'] ??
        sizes['SmallImageUrl'] ??
        // Fallback sur ThumbnailUrl
        thumbnailUrl;

    final isVideo = json['IsVideo'] == true;

    return MediaItem(
      id: json['ImageKey'], // Utilise ImageKey comme ID
      type: isVideo ? MediaType.video : MediaType.photo,
      tagGroup:
          'Sommet', // Pour le filtre, on pourrait utiliser le nom de l'album
      title:
          json['Title'] ??
          albumTitle, // Souvent les images n'ont pas de titre, on prend l'album
      timeLabel: (json['Date'] ?? '').toString().substring(0, 10),
      locationLabel:
          'Malabo', // Pas de location par défaut dans la réponse standard
      coverImageUrl: coverUrl,
      mediaUrl: mediaUrl,
      mimeType: isVideo ? 'video/mp4' : 'image/jpeg', // Approximation
    );
  }
}
