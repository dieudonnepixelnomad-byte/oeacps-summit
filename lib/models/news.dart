import 'package:html/parser.dart';

class NewsArticle {
  final String id;
  final String category;
  final DateTime date;
  final int readTimeMinutes;
  final String title;
  final String excerpt;
  final String content;
  final String heroImageUrl;
  final String? quoteText;
  final List<String> relatedIds;

  NewsArticle({
    required this.id,
    required this.category,
    required this.date,
    required this.readTimeMinutes,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.heroImageUrl,
    this.quoteText,
    required this.relatedIds,
  });

  NewsArticle copyWith({
    String? title,
    String? content,
    String? excerpt,
    String? category,
  }) {
    return NewsArticle(
      id: id,
      category: category ?? this.category,
      date: date,
      readTimeMinutes: readTimeMinutes,
      title: title ?? this.title,
      excerpt: excerpt ?? this.excerpt,
      content: content ?? this.content,
      heroImageUrl: heroImageUrl,
      relatedIds: relatedIds,
      quoteText: quoteText,
    );
  }

  factory NewsArticle.fromWordpressJson(Map<String, dynamic> json) {
    // Helper to strip HTML tags and decode entities
    String stripHtml(String htmlString) {
      final document = parse(htmlString);
      return document.body?.text.trim() ?? '';
    }

    // Extract image URL
    String imageUrl = 'assets/images/news_placeholder.png';
    if (json['_embedded'] != null &&
        json['_embedded']['wp:featuredmedia'] != null &&
        (json['_embedded']['wp:featuredmedia'] as List).isNotEmpty) {
      final media = json['_embedded']['wp:featuredmedia'][0];
      if (media['source_url'] != null) {
        imageUrl = media['source_url'];
      }
    }

    // Extract category
    String category = 'Actualité';
    if (json['_embedded'] != null &&
        json['_embedded']['wp:term'] != null &&
        (json['_embedded']['wp:term'] as List).isNotEmpty) {
      final terms = json['_embedded']['wp:term'][0] as List;
      if (terms.isNotEmpty && terms[0]['name'] != null) {
        category = terms[0]['name'];
      }
    }

    return NewsArticle(
      id: json['id'].toString(),
      category: category,
      date: DateTime.parse(json['date']),
      readTimeMinutes: 5, // Default read time
      title: stripHtml(
        json['title'] != null ? (json['title']['rendered'] ?? '') : '',
      ),
      excerpt: stripHtml(
        json['excerpt'] != null ? (json['excerpt']['rendered'] ?? '') : '',
      ),
      content: json['content'] != null
          ? (json['content']['rendered'] ?? '')
          : '', // Keep HTML for detail view
      heroImageUrl: imageUrl,
      relatedIds: [],
    );
  }
}
