import 'package:html/parser.dart';

enum MediaType { photo, video }

class MediaItem {
  final String id;
  final MediaType type;
  final String tagGroup;
  final String title;
  final String timeLabel;
  final String locationLabel;

  /// URL utilisée pour afficher une miniature (cover) dans l’app
  final String coverImageUrl;

  /// URL du fichier original
  final String mediaUrl;

  /// Mime type (utile pour filtrer proprement)
  final String mimeType;

  MediaItem({
    required this.id,
    required this.type,
    required this.tagGroup,
    required this.title,
    required this.timeLabel,
    required this.locationLabel,
    required this.coverImageUrl,
    required this.mediaUrl,
    required this.mimeType,
  });

  MediaItem copyWith({
    String? title,
    String? locationLabel,
    String? tagGroup,
  }) {
    return MediaItem(
      id: id,
      type: type,
      tagGroup: tagGroup ?? this.tagGroup,
      title: title ?? this.title,
      timeLabel: timeLabel,
      locationLabel: locationLabel ?? this.locationLabel,
      coverImageUrl: coverImageUrl,
      mediaUrl: mediaUrl,
      mimeType: mimeType,
    );
  }

  /// ✅ Ce que Flutter / Android décode le plus sûrement “out of the box”
  bool get isDisplayableCover {
    final m = mimeType.toLowerCase();

    // Images bitmap sûres
    final okMime =
        m == 'image/jpeg' ||
        m == 'image/jpg' ||
        m == 'image/png' ||
        m == 'image/gif' ||
        m == 'image/webp';

    if (okMime) return true;

    // Si WP ne donne pas mime_type (rare), fallback par extension
    final url = coverImageUrl.toLowerCase();
    final okExt =
        url.endsWith('.jpg') ||
        url.endsWith('.jpeg') ||
        url.endsWith('.png') ||
        url.endsWith('.gif') ||
        url.endsWith('.webp');

    return okExt;
  }

  /// ✅ Exclure explicitement les formats qui cassent souvent Image.network:
  bool get isLikelyUnsupportedByImageNetwork {
    final m = mimeType.toLowerCase();
    if (m.contains('svg')) return true; // image/svg+xml
    if (m.contains('pdf')) return true; // application/pdf
    if (m.contains('avif')) return true; // image/avif (selon devices/engine)
    return false;
  }

  factory MediaItem.fromWordpressJson(Map<String, dynamic> json) {
    String stripHtml(String htmlString) {
      final document = parse(htmlString);
      return document.body?.text.trim() ?? '';
    }

    final details = (json['media_details'] as Map?) ?? const {};
    final sizes = (details['sizes'] as Map?) ?? const {};

    final mimeType = (json['mime_type'] ?? '').toString();
    final sourceUrl = (json['source_url'] ?? '').toString();

    // 🎯 Choix cover: medium_large > large > medium > full > source_url
    String coverUrl = sourceUrl;
    if (sizes.containsKey('medium_large')) {
      coverUrl = sizes['medium_large']['source_url'];
    } else if (sizes.containsKey('large')) {
      coverUrl = sizes['large']['source_url'];
    } else if (sizes.containsKey('medium')) {
      coverUrl = sizes['medium']['source_url'];
    }

    final title = stripHtml(json['title']?['rendered'] ?? '');

    return MediaItem(
      id: json['id'].toString(),
      type: mimeType.startsWith('video') ? MediaType.video : MediaType.photo,
      tagGroup: 'Archives', // Par défaut
      title: title,
      timeLabel: (json['date'] ?? '').toString().substring(0, 10),
      locationLabel: '',
      coverImageUrl: coverUrl,
      mediaUrl: sourceUrl,
      mimeType: mimeType,
    );
  }
}

class Album {
  final String id;
  final String title;
  final String coverImageUrl;
  final String dateLabel;
  final int imageCount;
  final String urlKey;

  Album({
    required this.id,
    required this.title,
    required this.coverImageUrl,
    required this.dateLabel,
    required this.imageCount,
    required this.urlKey,
  });
}
