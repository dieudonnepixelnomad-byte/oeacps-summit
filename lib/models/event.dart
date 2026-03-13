import 'package:html/parser.dart';
import 'dart:developer' as developer;
import 'program.dart';
import 'speaker.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final List<ProgramDay> program;
  final List<String> speakerIds;
  final List<Speaker> embeddedSpeakers; // Speakers loaded directly with event

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.program,
    required this.speakerIds,
    this.embeddedSpeakers = const [],
  });

  factory Event.fromCustomApiJson(Map<String, dynamic> json) {
    developer.log(
      'Parsing Event from CustomApiJson: $json',
      name: 'Event.fromCustomApiJson',
    );

    String stripHtml(String htmlString) {
      final document = parse(htmlString);
      return document.body?.text.trim() ?? '';
    }

    // Dates
    DateTime start = DateTime.now();
    DateTime end = DateTime.now();

    if (json['start_date'] != null) {
      try {
        start = DateTime.parse(json['start_date']);
      } catch (_) {}
    }

    if (json['end_date'] != null) {
      try {
        end = DateTime.parse(json['end_date']);
      } catch (_) {
        end = start;
      }
    } else {
      end = start;
    }

    // Speakers
    List<String> speakerIds = [];
    List<Speaker> embeddedSpeakers = [];
    if (json['speakers'] != null) {
      for (var s in json['speakers']) {
        if (s['id'] != null) {
          speakerIds.add(s['id'].toString());
          embeddedSpeakers.add(Speaker.fromCustomApiJson(s));
        }
      }
    }

    // Location Parsing
    String location = 'Lieu à définir';
    if (json['location'] != null) {
      if (json['location'] is Map) {
        // Handle {address: ..., city: ...} structure
        final locMap = json['location'];
        if (locMap['address'] != null &&
            locMap['address'].toString().isNotEmpty) {
          location = locMap['address'].toString();
        } else if (locMap['city'] != null) {
          location = locMap['city'].toString();
        }
      } else if (json['location'] is String) {
        // Handle "String" structure or JSON string
        String locStr = json['location'];
        if (locStr.startsWith('{') && locStr.contains('address')) {
          // Try to clean up if it's a stringified map representation like "{address: ...}"
          // Regex to extract address value: address: (.*?)(,|})
          final RegExp regex = RegExp(r'address:\s*([^,}]+)');
          final match = regex.firstMatch(locStr);
          if (match != null && match.group(1) != null) {
            location = match.group(1)!.trim();
          } else {
            location = locStr;
          }
        } else {
          location = locStr;
        }
      }
    }

    // Description logic: prefer plain text (converted to HTML breaks) for better translation
    String description = '';
    if (json['description_plain'] != null &&
        json['description_plain'].toString().isNotEmpty) {
      description = json['description_plain'].toString().replaceAll(
        '\n',
        '<br />',
      );
    } else {
      // Fallback: strip HTML from description to ensure clean translation if possible,
      // or just keep it if you prefer raw HTML (but raw HTML often fails translation).
      // Given the user issue, we prefer stripping to ensure translation works.
      final rawDesc = json['description'] ?? '';
      description = stripHtml(rawDesc).replaceAll('\n', '<br />');
    }

    return Event(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: description,
      imageUrl: json['banner'] ?? 'assets/images/event_placeholder.jpg',
      startDate: start,
      endDate: end,
      location: location,
      program: [], // Will be populated separately via schedule endpoint
      speakerIds: speakerIds,
      embeddedSpeakers: embeddedSpeakers,
    );
  }

  // Factory for EventIn API (wp-json/eventin/v2/events)
  factory Event.fromEventInJson(Map<String, dynamic> json) {
    developer.log(
      'Parsing Event from EventInJson: $json',
      name: 'Event.fromEventInJson',
    );
    String stripHtml(String htmlString) {
      final document = parse(htmlString);
      return document.body?.text.trim() ?? '';
    }

    // Image extraction logic
    String imageUrl = 'assets/images/event_placeholder.jpg';
    if (json['_embedded'] != null &&
        json['_embedded']['wp:featuredmedia'] != null &&
        (json['_embedded']['wp:featuredmedia'] as List).isNotEmpty) {
      final media = json['_embedded']['wp:featuredmedia'][0];
      if (media['source_url'] != null) {
        imageUrl = media['source_url'];
      }
    }

    // Date parsing logic
    DateTime start = DateTime.now();
    DateTime end = DateTime.now();

    if (json['etn_start_date'] != null) {
      try {
        start = DateTime.parse(json['etn_start_date']);
      } catch (e) {
        // Ignore parse error
      }
    } else if (json['date'] != null) {
      start = DateTime.parse(json['date']);
    }

    if (json['etn_end_date'] != null) {
      try {
        end = DateTime.parse(json['etn_end_date']);
      } catch (e) {
        end = start;
      }
    } else {
      end = start;
    }

    // Location
    String location = 'Lieu à définir';
    if (json['etn_location'] != null) {
      location = json['etn_location'].toString();
    } else if (json['meta'] != null && json['meta']['etn_location'] != null) {
      location = json['meta']['etn_location'].toString();
    }

    return Event(
      id: json['id'].toString(),
      title: stripHtml(
        json['title'] != null ? (json['title']['rendered'] ?? '') : '',
      ),
      description: stripHtml(
        json['content'] != null ? (json['content']['rendered'] ?? '') : '',
      ),
      imageUrl: imageUrl,
      startDate: start,
      endDate: end,
      location: location,
      program: [],
      speakerIds: [],
    );
  }

  // Factory for WordPress Custom Post Type API (wp-json/wp/v2/etn)
  factory Event.fromWordpressJson(Map<String, dynamic> json) {
    developer.log(
      'Parsing Event from WordpressJson: $json',
      name: 'Event.fromWordpressJson',
    );
    String stripHtml(String htmlString) {
      final document = parse(htmlString);
      return document.body?.text.trim() ?? '';
    }

    // Image extraction logic
    String imageUrl = 'assets/images/event_placeholder.jpg';
    if (json['_embedded'] != null &&
        json['_embedded']['wp:featuredmedia'] != null &&
        (json['_embedded']['wp:featuredmedia'] as List).isNotEmpty) {
      final media = json['_embedded']['wp:featuredmedia'][0];
      if (media['source_url'] != null) {
        imageUrl = media['source_url'];
      }
    }

    // Try to find dates in ACF or Meta if available, otherwise fallback to post date
    DateTime start = DateTime.now();
    DateTime end = DateTime.now();

    // Note: Standard WP API for CPT might not expose custom fields directly in root
    // unless 'acf' is exposed in REST API.
    // We try to look for common field names or fallback to post date.

    if (json['date'] != null) {
      start = DateTime.parse(json['date']);
      end = start; // Default to start date if end date not found
    }

    // Attempt to read from 'acf' if present
    if (json['acf'] != null) {
      final acf = json['acf'];
      if (acf['etn_start_date'] != null) {
        try {
          start = DateTime.parse(acf['etn_start_date']);
        } catch (_) {}
      }
      if (acf['etn_end_date'] != null) {
        try {
          end = DateTime.parse(acf['etn_end_date']);
        } catch (_) {}
      }
    }

    // Location
    String location = 'Lieu à définir';
    if (json['acf'] != null && json['acf']['etn_location'] != null) {
      location = json['acf']['etn_location'].toString();
    } else if (json['meta'] != null && json['meta']['etn_location'] != null) {
      location = json['meta']['etn_location'].toString();
    }

    return Event(
      id: json['id'].toString(),
      title: stripHtml(
        json['title'] != null ? (json['title']['rendered'] ?? '') : '',
      ),
      description: stripHtml(
        json['content'] != null ? (json['content']['rendered'] ?? '') : '',
      ),
      imageUrl: imageUrl,
      startDate: start,
      endDate: end,
      location: location,
      program: [],
      speakerIds: [],
    );
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    List<ProgramDay>? program,
    List<String>? speakerIds,
    List<Speaker>? embeddedSpeakers,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      program: program ?? this.program,
      speakerIds: speakerIds ?? this.speakerIds,
      embeddedSpeakers: embeddedSpeakers ?? this.embeddedSpeakers,
    );
  }
}
