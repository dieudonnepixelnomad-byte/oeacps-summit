import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:summitoeacp/models/program.dart';
import 'package:summitoeacp/models/speaker.dart';
import 'translation_service.dart';

import '../utils/constants.dart';
import '../models/news.dart';
import '../models/media.dart';
import '../models/event.dart';

class CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  CacheEntry(this.data, this.timestamp);
}

class WordpressService {
  final Map<String, CacheEntry> _cache = {};
  final Duration _cacheDuration = const Duration(minutes: 15);
  final TranslationService _translationService = TranslationService();

  /// Headers communs (public read-only)
  Map<String, String> _getHeaders() {
    return {
      'Accept': 'application/json',
      // Pas d'Authorization dans une app vitrine
    };
  }

  /// Envoie une demande d'accréditation avec pièce jointe
  Future<bool> sendAccreditationRequest({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String category,
    required String country,
    required String organization,
    String? filePath,
  }) async {
    // URL du endpoint personnalisé (à adapter selon votre hébergement)
    // Exemple: https://summitoacps.com/wp-json/oeacp/v1/accreditation
    final url = Uri.parse('https://summitoacps.com/wp-json/oeacp/v1/accreditation');

    try {
      final request = http.MultipartRequest('POST', url);
      
      // Champs texte
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      request.fields['email'] = email;
      request.fields['phone'] = phone;
      request.fields['category'] = category;
      request.fields['country'] = country;
      request.fields['organization'] = organization;

      // Fichier joint (si présent)
      if (filePath != null && filePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('document', filePath),
        );
      }

      developer.log('Sending accreditation request to $url', name: 'WordpressService');
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      developer.log('Accreditation response status: ${response.statusCode}', name: 'WordpressService');
      developer.log('Accreditation response body: ${response.body}', name: 'WordpressService');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      developer.log('Error sending accreditation: $e', name: 'WordpressService', error: e);
      return false;
    }
  }

  /// Récupère la page "À propos"
  Future<Map<String, dynamic>?> getAboutPage({String lang = 'fr'}) async {
    final url = kApiAboutPage;

    final cacheKey = '${url}_$lang';
    if (_cache.containsKey(cacheKey)) {
      final entry = _cache[cacheKey]!;
      if (DateTime.now().difference(entry.timestamp) < _cacheDuration) {
        return entry.data as Map<String, dynamic>;
      }
    }

    // Récupération base (FR)
    Map<String, dynamic>? page;
    final baseCacheKey = url;
    if (_cache.containsKey(baseCacheKey) &&
        DateTime.now().difference(_cache[baseCacheKey]!.timestamp) <
            _cacheDuration) {
      page = _cache[baseCacheKey]!.data as Map<String, dynamic>;
    } else {
      page = await _fetchSingle(url, (json) => json);
      if (page != null) {
        _cache[baseCacheKey] = CacheEntry(page, DateTime.now());
      }
    }

    if (page == null) return null;
    if (lang == 'fr') return page;

    try {
      final title = page['title']['rendered'] ?? '';
      final content = page['content']['rendered'] ?? '';

      final translated = await _translationService.translateTexts(
        texts: [title, content],
        toLang: lang,
      );

      if (translated.length != 2) return page;

      final translatedPage = Map<String, dynamic>.from(page);
      translatedPage['title'] = {'rendered': translated[0]};
      translatedPage['content'] = {'rendered': translated[1]};

      _cache[cacheKey] = CacheEntry(translatedPage, DateTime.now());
      return translatedPage;
    } catch (e) {
      developer.log(
        'Translation error in getAboutPage: $e',
        name: 'WordpressService',
      );
      return page;
    }
  }

  /// Récupère les actualités
  Future<List<NewsArticle>> getNews({
    int page = 1,
    int perPage = 10,
    String lang = 'fr',
  }) async {
    final url = '$kApiPosts&page=$page&per_page=$perPage';

    final cacheKey = '${url}_$lang';
    if (_cache.containsKey(cacheKey)) {
      final entry = _cache[cacheKey]!;
      if (DateTime.now().difference(entry.timestamp) < _cacheDuration) {
        return entry.data as List<NewsArticle>;
      }
    }

    // Récupération base (FR)
    final news = await _fetchList(
      url,
      (json) => NewsArticle.fromWordpressJson(json),
    );

    if (lang == 'fr') return news;

    try {
      final newsToTranslate = List<NewsArticle>.from(news);
      final titles = newsToTranslate.map((n) => n.title).toList();
      final excerpts = newsToTranslate.map((n) => n.excerpt).toList();
      final contents = newsToTranslate.map((n) => n.content).toList();
      final categories = newsToTranslate.map((n) => n.category).toList();

      final allTexts = [...titles, ...excerpts, ...contents, ...categories];
      final translated = await _translationService.translateTexts(
        texts: allTexts,
        toLang: lang,
      );

      final count = newsToTranslate.length;
      // Safety check
      if (translated.length != count * 4) {
        return news; // Translation failed partial or mismatched
      }

      final tTitles = translated.sublist(0, count);
      final tExcerpts = translated.sublist(count, count * 2);
      final tContents = translated.sublist(count * 2, count * 3);
      final tCategories = translated.sublist(count * 3, count * 4);

      final translatedNews = <NewsArticle>[];
      for (int i = 0; i < count; i++) {
        translatedNews.add(
          newsToTranslate[i].copyWith(
            title: tTitles[i],
            excerpt: tExcerpts[i],
            content: tContents[i],
            category: tCategories[i],
          ),
        );
      }

      _cache[cacheKey] = CacheEntry(translatedNews, DateTime.now());
      return translatedNews;
    } catch (e) {
      developer.log(
        'Translation error in getNews: $e',
        name: 'WordpressService',
      );
      return news;
    }
  }

  /// Récupère un article unique par ID
  Future<NewsArticle?> getNewsArticle(String id, {String lang = 'fr'}) async {
    final url = '$kApiPosts&include=$id';

    final cacheKey = '${url}_$lang';
    if (_cache.containsKey(cacheKey)) {
      final entry = _cache[cacheKey]!;
      if (DateTime.now().difference(entry.timestamp) < _cacheDuration) {
        return entry.data as NewsArticle;
      }
    }

    // Récupération base (FR)
    NewsArticle? article;
    final baseCacheKey = url;
    if (_cache.containsKey(baseCacheKey) &&
        DateTime.now().difference(_cache[baseCacheKey]!.timestamp) <
            _cacheDuration) {
      article = _cache[baseCacheKey]!.data as NewsArticle;
    } else {
      // WP API pour un seul post via ?include=ID renvoie une liste de 1 élément
      final list = await _fetchList(
        url,
        (json) => NewsArticle.fromWordpressJson(json),
      );
      if (list.isNotEmpty) {
        article = list.first;
        _cache[baseCacheKey] = CacheEntry(article, DateTime.now());
      }
    }

    if (article == null) return null;
    if (lang == 'fr') return article;

    try {
      // Simplification: Envoi du contenu entier.
      // Le découpage par balises HTML peut perturber le service de traduction.
      final texts = [
        article.title,
        article.excerpt,
        article.category,
        article.content,
      ];

      developer.log(
        'Translating article ${article.id} to $lang.',
        name: 'WordpressService',
      );

      final translated = await _translationService.translateTexts(
        texts: texts,
        toLang: lang,
      );

      if (translated.length != 4) {
        developer.log(
          'Translation mismatch: expected 4, got ${translated.length}',
          name: 'WordpressService',
        );
        return article;
      }

      final translatedTitle = translated[0];
      final translatedExcerpt = translated[1];
      final translatedCategory = translated[2];
      final translatedContent = translated[3];

      final translatedArticle = article.copyWith(
        title: translatedTitle,
        excerpt: translatedExcerpt,
        content: translatedContent,
        category: translatedCategory,
      );

      _cache[cacheKey] = CacheEntry(translatedArticle, DateTime.now());
      return translatedArticle;
    } catch (e) {
      developer.log(
        'Translation error in getNewsArticle: $e',
        name: 'WordpressService',
      );
      return article;
    }
  }

  /// Récupère les médias (photos/vidéos)
  Future<List<MediaItem>> getMedia({
    int page = 1,
    int perPage = 20,
    String lang = 'fr',
  }) async {
    final uri = Uri.parse(kApiMedia).replace(
      queryParameters: {
        '_embed': '1',
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
    );

    final cacheKey = '${uri.toString()}_$lang';
    if (_cache.containsKey(cacheKey)) {
      final entry = _cache[cacheKey]!;
      if (DateTime.now().difference(entry.timestamp) < _cacheDuration) {
        return entry.data as List<MediaItem>;
      }
    }

    final list = await _fetchList(
      uri.toString(),
      (json) => MediaItem.fromWordpressJson(json),
    );

    final filteredList = list
        .where(
          (m) =>
              m.coverImageUrl.isNotEmpty &&
              !m.isLikelyUnsupportedByImageNetwork &&
              m.isDisplayableCover,
        )
        .toList();

    if (lang == 'fr') return filteredList;

    try {
      final mediaToTranslate = List<MediaItem>.from(filteredList);
      final titles = mediaToTranslate.map((m) => m.title).toList();
      final locationLabels = mediaToTranslate
          .map((m) => m.locationLabel)
          .toList();
      final tagGroups = mediaToTranslate.map((m) => m.tagGroup).toList();

      final allTexts = [...titles, ...locationLabels, ...tagGroups];
      final translated = await _translationService.translateTexts(
        texts: allTexts,
        toLang: lang,
      );

      final count = mediaToTranslate.length;
      if (translated.length != count * 3) {
        return filteredList;
      }

      final tTitles = translated.sublist(0, count);
      final tLocations = translated.sublist(count, count * 2);
      final tTags = translated.sublist(count * 2, count * 3);

      final translatedMedia = <MediaItem>[];
      for (int i = 0; i < count; i++) {
        translatedMedia.add(
          mediaToTranslate[i].copyWith(
            title: tTitles[i],
            locationLabel: tLocations[i],
            tagGroup: tTags[i],
          ),
        );
      }

      _cache[cacheKey] = CacheEntry(translatedMedia, DateTime.now());
      return translatedMedia;
    } catch (e) {
      developer.log(
        'Translation error in getMedia: $e',
        name: 'WordpressService',
      );
      return filteredList;
    }
  }

  Future<MediaItem?> getMediaById(String id, {String lang = 'fr'}) async {
    final url = '$kAppApiMediaUrl/$id';

    final cacheKey = '${url}_$lang';
    if (_cache.containsKey(cacheKey)) {
      final entry = _cache[cacheKey]!;
      if (DateTime.now().difference(entry.timestamp) < _cacheDuration) {
        return entry.data as MediaItem;
      }
    }

    final item = await _fetchSingle(url, (json) {
      // On mappe le JSON custom → MediaItem
      final String typeStr = (json['type'] ?? 'photo').toString();
      final MediaType type = typeStr == 'video'
          ? MediaType.video
          : MediaType.photo;

      final String title = (json['title'] ?? '').toString();
      final String date = (json['date'] ?? '').toString();

      // ✅ Toujours thumbnail (stable)
      final String thumb = (json['thumbnail_url'] ?? '').toString();
      final String source = (json['source_url'] ?? '').toString();
      final String mime = (json['mime_type'] ?? '').toString();

      return MediaItem(
        id: (json['id']).toString(),
        type: type,
        tagGroup: 'Sommet',
        title: title.isNotEmpty ? title : 'Media',
        timeLabel: date.isNotEmpty ? date.substring(0, 10) : '',
        locationLabel: '',
        coverImageUrl: thumb.isNotEmpty ? thumb : source,
        mediaUrl: source,
        mimeType: mime,
      );
    });

    if (item == null) return null;
    if (lang == 'fr') return item;

    try {
      final texts = [item.title, item.locationLabel, item.tagGroup];
      final translated = await _translationService.translateTexts(
        texts: texts,
        toLang: lang,
      );

      if (translated.length != 3) {
        return item;
      }

      final translatedItem = item.copyWith(
        title: translated[0],
        locationLabel: translated[1],
        tagGroup: translated[2],
      );

      _cache[cacheKey] = CacheEntry(translatedItem, DateTime.now());
      return translatedItem;
    } catch (e) {
      developer.log(
        'Translation error in getMediaById: $e',
        name: 'WordpressService',
      );
      return item;
    }
  }

  Future<List<ProgramDay>> getProgram({String lang = 'fr'}) async {
    final url = '$kCustomApiProgramUrl?per_page=200&order=ASC';

    final cacheKey = '${url}_$lang';
    if (_cache.containsKey(cacheKey)) {
      final entry = _cache[cacheKey]!;
      if (DateTime.now().difference(entry.timestamp) < _cacheDuration) {
        return entry.data as List<ProgramDay>;
      }
    }

    // Récupération base (FR)
    List<ProgramDay> program;
    final baseCacheKey = url;
    if (_cache.containsKey(baseCacheKey) &&
        DateTime.now().difference(_cache[baseCacheKey]!.timestamp) <
            _cacheDuration) {
      program = _cache[baseCacheKey]!.data as List<ProgramDay>;
    } else {
      developer.log('Fetching program from: $url', name: 'WordpressService');
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) {
        developer.log('Program error: ${res.body}', name: 'WordpressService');
        throw Exception('Erreur récupération programme');
      }

      final decoded = jsonDecode(res.body);
      final List data = decoded['data'] ?? [];
      program = data
          .whereType<Map<String, dynamic>>()
          .map((d) => ProgramDay.fromCustomApiJson(d))
          .toList();

      _cache[baseCacheKey] = CacheEntry(program, DateTime.now());
    }

    if (lang == 'fr') return program;

    try {
      final translatedProgram = await _translateProgramList(program, lang);

      _cache[cacheKey] = CacheEntry(translatedProgram, DateTime.now());
      return translatedProgram;
    } catch (e) {
      developer.log(
        'Translation error in getProgram: $e',
        name: 'WordpressService',
      );
      return program;
    }
  }

  Future<List<Event>> getEvents({String lang = 'fr'}) async {
    final url = '$kCustomApiEventsUrl?per_page=50&order=ASC';

    // 1. Récupération des données (FR par défaut)
    // On utilise _fetchList pour bénéficier du cache
    // Note: getEvents utilisait http.get direct avant, on passe par _fetchList pour uniformiser
    // Mais le format de réponse est {data: [...]}, ce que _fetchList gère

    // Clé de cache spécifique pour la langue
    final cacheKey = '${url}_$lang';
    if (_cache.containsKey(cacheKey)) {
      final entry = _cache[cacheKey]!;
      if (DateTime.now().difference(entry.timestamp) < _cacheDuration) {
        developer.log('Cache hit for $cacheKey', name: 'WordpressService');
        return entry.data as List<Event>;
      }
    }

    // Si pas en cache (ou expiré), on récupère la base (FR)
    // On force le fetch de la base si on ne l'a pas
    List<Event> events;
    try {
      // On récupère d'abord les événements "bruts" (FR) via _fetchList ou logique similaire
      // Pour ne pas casser la logique existante de _fetchList qui attend une structure spécifique
      // On va utiliser la logique existante de getEvents mais avec cache manuel

      // Check cache FR base
      final baseCacheKey = url;
      if (_cache.containsKey(baseCacheKey) &&
          DateTime.now().difference(_cache[baseCacheKey]!.timestamp) <
              _cacheDuration) {
        developer.log('Cache hit for $baseCacheKey', name: 'WordpressService');
        events = _cache[baseCacheKey]!.data as List<Event>;
      } else {
        developer.log('Fetching events from: $url', name: 'WordpressService');
        final res = await http.get(Uri.parse(url));
        if (res.statusCode != 200) {
          throw Exception('Erreur récupération events');
        }

        final decoded = jsonDecode(res.body);
        final List data = decoded['data'] ?? [];
        events = data
            .whereType<Map<String, dynamic>>()
            .map((e) => Event.fromCustomApiJson(e))
            .toList();

        // Cache FR base
        _cache[baseCacheKey] = CacheEntry(events, DateTime.now());
      }

      // 2. Traduction si nécessaire
      if (lang != 'fr') {
        developer.log('Translating events to $lang', name: 'WordpressService');

        // On ne modifie pas la liste originale (cache FR)
        final eventsToTranslate = List<Event>.from(events);

        final titles = eventsToTranslate.map((e) => e.title).toList();
        final descriptions = eventsToTranslate
            .map((e) => e.description)
            .toList();

        // Speakers flattening
        final allSpeakers = eventsToTranslate
            .expand((e) => e.embeddedSpeakers)
            .toList();
        final sNames = allSpeakers.map((s) => s.fullName).toList();
        final sRoles = allSpeakers.map((s) => s.titleRole).toList();
        final sBios = allSpeakers.map((s) => s.bio).toList();
        final sOrgs = allSpeakers.map((s) => s.organization).toList();

        // Traduction par lots (titres + descriptions + speakers)
        final allTexts = [
          ...titles,
          ...descriptions,
          ...sNames,
          ...sRoles,
          ...sBios,
          ...sOrgs,
        ];

        final translated = await _translationService.translateTexts(
          texts: allTexts,
          toLang: lang,
        );

        final eventCount = eventsToTranslate.length;
        final speakerCount = allSpeakers.length;

        if (translated.length != (eventCount * 2) + (speakerCount * 4)) {
          return events;
        }

        int offset = 0;
        final tTitles = translated.sublist(offset, offset + eventCount);
        offset += eventCount;

        final tDescs = translated.sublist(offset, offset + eventCount);
        offset += eventCount;

        final tSNames = translated.sublist(offset, offset + speakerCount);
        offset += speakerCount;

        final tSRoles = translated.sublist(offset, offset + speakerCount);
        offset += speakerCount;

        final tSBios = translated.sublist(offset, offset + speakerCount);
        offset += speakerCount;

        final tSOrgs = translated.sublist(offset, offset + speakerCount);

        // Reconstruct speakers
        final translatedSpeakers = <Speaker>[];
        for (int i = 0; i < speakerCount; i++) {
          translatedSpeakers.add(
            allSpeakers[i].copyWith(
              fullName: tSNames[i],
              titleRole: tSRoles[i],
              bio: tSBios[i],
              organization: tSOrgs[i],
            ),
          );
        }

        final translatedEvents = <Event>[];
        int speakerIndex = 0;

        for (int i = 0; i < eventCount; i++) {
          final originalEvent = eventsToTranslate[i];
          final currentEventSpeakerCount =
              originalEvent.embeddedSpeakers.length;
          final eventSpeakers = translatedSpeakers
              .sublist(speakerIndex, speakerIndex + currentEventSpeakerCount)
              .toList();
          speakerIndex += currentEventSpeakerCount;

          translatedEvents.add(
            originalEvent.copyWith(
              title: tTitles[i],
              description: tDescs[i],
              embeddedSpeakers: eventSpeakers,
            ),
          );
        }

        // Cache translated result
        _cache[cacheKey] = CacheEntry(translatedEvents, DateTime.now());
        return translatedEvents;
      }

      developer.log('Returning events in $lang', name: 'WordpressService');

      return events;
    } catch (e) {
      developer.log('Error in getEvents: $e', name: 'WordpressService');
      return []; // Ou rethrow
    }
  }

  Future<Event?> getEvent(int id, {String lang = 'fr'}) async {
    final url = customEventDetailUrl(id);

    final cacheKey = '${url}_$lang';
    if (_cache.containsKey(cacheKey)) {
      final entry = _cache[cacheKey]!;
      if (DateTime.now().difference(entry.timestamp) < _cacheDuration) {
        return entry.data as Event;
      }
    }

    // Fetch base FR
    Event? event;
    final baseCacheKey = url;
    if (_cache.containsKey(baseCacheKey) &&
        DateTime.now().difference(_cache[baseCacheKey]!.timestamp) <
            _cacheDuration) {
      event = _cache[baseCacheKey]!.data as Event;
    } else {
      developer.log(
        'Fetching event details from: $url',
        name: 'WordpressService',
      );
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) return null;

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      event = Event.fromCustomApiJson(decoded);
      _cache[baseCacheKey] = CacheEntry(event, DateTime.now());
    }

    if (lang == 'fr') return event;

    try {
      final sNames = event.embeddedSpeakers.map((s) => s.fullName).toList();
      final sRoles = event.embeddedSpeakers.map((s) => s.titleRole).toList();
      final sBios = event.embeddedSpeakers.map((s) => s.bio).toList();
      final sOrgs = event.embeddedSpeakers.map((s) => s.organization).toList();

      final texts = [
        event.title,
        event.description,
        event.location,
        ...sNames,
        ...sRoles,
        ...sBios,
        ...sOrgs,
      ];

      final translated = await _translationService.translateTexts(
        texts: texts,
        toLang: lang,
      );

      var translatedEvent = event;
      final speakerCount = event.embeddedSpeakers.length;

      if (translated.length == 3 + (speakerCount * 4)) {
        final tTitle = translated[0];
        final tDesc = translated[1];
        final tLoc = translated[2];

        int offset = 3;
        final tSNames = translated.sublist(offset, offset + speakerCount);
        offset += speakerCount;

        final tSRoles = translated.sublist(offset, offset + speakerCount);
        offset += speakerCount;

        final tSBios = translated.sublist(offset, offset + speakerCount);
        offset += speakerCount;

        final tSOrgs = translated.sublist(offset, offset + speakerCount);

        final translatedSpeakers = <Speaker>[];
        for (int i = 0; i < speakerCount; i++) {
          translatedSpeakers.add(
            event.embeddedSpeakers[i].copyWith(
              fullName: tSNames[i],
              titleRole: tSRoles[i],
              bio: tSBios[i],
              organization: tSOrgs[i],
            ),
          );
        }

        translatedEvent = translatedEvent.copyWith(
          title: tTitle,
          description: tDesc,
          location: tLoc,
          embeddedSpeakers: translatedSpeakers,
        );
      }

      if (translatedEvent.program.isNotEmpty) {
        final translatedProgram = await _translateProgramList(
          translatedEvent.program,
          lang,
        );
        translatedEvent = translatedEvent.copyWith(program: translatedProgram);
      }

      _cache[cacheKey] = CacheEntry(translatedEvent, DateTime.now());
      return translatedEvent;
    } catch (e) {
      developer.log(
        'Translation error in getEvent: $e',
        name: 'WordpressService',
      );
      return event;
    }
  }

  Future<List<Speaker>> getSpeakers({String lang = 'fr'}) async {
    final url = '$kApiSpeakers?per_page=200&page=1';

    final cacheKey = '${url}_$lang';
    if (_cache.containsKey(cacheKey)) {
      final entry = _cache[cacheKey]!;
      if (DateTime.now().difference(entry.timestamp) < _cacheDuration) {
        return entry.data as List<Speaker>;
      }
    }

    // Récupération base (FR)
    List<Speaker> speakers;
    final baseCacheKey = url;
    if (_cache.containsKey(baseCacheKey) &&
        DateTime.now().difference(_cache[baseCacheKey]!.timestamp) <
            _cacheDuration) {
      speakers = _cache[baseCacheKey]!.data as List<Speaker>;
    } else {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) {
        throw Exception('Erreur récupération speakers');
      }

      final decoded = jsonDecode(res.body);
      final List data = decoded['data'] ?? [];
      speakers = data
          .whereType<Map<String, dynamic>>()
          .map((s) => Speaker.fromCustomApiJson(s))
          .toList();

      _cache[baseCacheKey] = CacheEntry(speakers, DateTime.now());
    }

    if (lang == 'fr') return speakers;

    try {
      final speakersToTranslate = List<Speaker>.from(speakers);

      final names = speakersToTranslate.map((s) => s.fullName).toList();
      final roles = speakersToTranslate.map((s) => s.titleRole).toList();
      final bios = speakersToTranslate.map((s) => s.bio).toList();
      final orgs = speakersToTranslate.map((s) => s.organization).toList();

      final allTexts = [...names, ...roles, ...bios, ...orgs];
      final translated = await _translationService.translateTexts(
        texts: allTexts,
        toLang: lang,
      );

      final count = speakersToTranslate.length;
      if (translated.length != count * 4) {
        return speakers;
      }

      final tNames = translated.sublist(0, count);
      final tRoles = translated.sublist(count, count * 2);
      final tBios = translated.sublist(count * 2, count * 3);
      final tOrgs = translated.sublist(count * 3, count * 4);

      final translatedSpeakers = <Speaker>[];
      for (int i = 0; i < count; i++) {
        translatedSpeakers.add(
          speakersToTranslate[i].copyWith(
            fullName: tNames[i],
            titleRole: tRoles[i],
            bio: tBios[i],
            organization: tOrgs[i],
          ),
        );
      }

      _cache[cacheKey] = CacheEntry(translatedSpeakers, DateTime.now());
      return translatedSpeakers;
    } catch (e) {
      developer.log(
        'Translation error in getSpeakers: $e',
        name: 'WordpressService',
      );
      return speakers;
    }
  }

  Future<List<ProgramDay>> _translateProgramList(
    List<ProgramDay> program,
    String lang,
  ) async {
    try {
      final programToTranslate = List<ProgramDay>.from(program);

      final dayLabels = programToTranslate.map((d) => d.label).toList();
      final dateLabels = programToTranslate.map((d) => d.dateLabel).toList();
      final allSessions = programToTranslate.expand((d) => d.sessions).toList();

      final sessionTitles = allSessions.map((s) => s.title).toList();
      final sessionDescs = allSessions.map((s) => s.description).toList();
      final sessionLocs = allSessions.map((s) => s.locationName).toList();

      final allTexts = [
        ...dayLabels,
        ...dateLabels,
        ...sessionTitles,
        ...sessionDescs,
        ...sessionLocs,
      ];

      final translated = await _translationService.translateTexts(
        texts: allTexts,
        toLang: lang,
      );

      final dayCount = dayLabels.length;
      final sessionCount = allSessions.length;

      if (translated.length != (dayCount * 2) + (sessionCount * 3)) {
        return program;
      }

      int offset = 0;
      final tDayLabels = translated.sublist(offset, offset + dayCount);
      offset += dayCount;

      final tDateLabels = translated.sublist(offset, offset + dayCount);
      offset += dayCount;

      final tSessionTitles = translated.sublist(offset, offset + sessionCount);
      offset += sessionCount;

      final tSessionDescs = translated.sublist(offset, offset + sessionCount);
      offset += sessionCount;

      final tSessionLocs = translated.sublist(offset, offset + sessionCount);

      final translatedProgram = <ProgramDay>[];
      int sessionIndex = 0;

      for (int i = 0; i < dayCount; i++) {
        final originalDay = programToTranslate[i];
        final daySessions = <Session>[];

        for (int j = 0; j < originalDay.sessions.length; j++) {
          final originalSession = originalDay.sessions[j];
          daySessions.add(
            originalSession.copyWith(
              title: tSessionTitles[sessionIndex],
              description: tSessionDescs[sessionIndex],
              locationName: tSessionLocs[sessionIndex],
            ),
          );
          sessionIndex++;
        }

        translatedProgram.add(
          originalDay.copyWith(
            label: tDayLabels[i],
            dateLabel: tDateLabels[i],
            sessions: daySessions,
          ),
        );
      }
      return translatedProgram;
    } catch (e) {
      developer.log(
        'Translation error in _translateProgramList: $e',
        name: 'WordpressService',
      );
      return program;
    }
  }

  /// Méthode générique pour récupérer une liste d'objets depuis l'API avec Caching
  Future<List<T>> _fetchList<T>(
    String url,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    if (_cache.containsKey(url)) {
      final entry = _cache[url]!;
      if (DateTime.now().difference(entry.timestamp) < _cacheDuration) {
        developer.log('Cache hit for $url', name: 'WordpressService');
        return entry.data as List<T>;
      }
    }

    developer.log('Fetching list from: $url', name: 'WordpressService');

    final response = await http.get(Uri.parse(url), headers: _getHeaders());

    developer.log(
      'Response status: ${response.statusCode} for $url',
      name: 'WordpressService',
    );

    if (response.statusCode != 200) {
      developer.log(
        'HTTP error ${response.statusCode} on $url',
        name: 'WordpressService',
        error: response.body,
      );
      return [];
    }

    final dynamic decoded = json.decode(response.body);

    // 1) WP endpoints renvoient souvent une List
    // 2) Ton API custom renvoie un Map { data: [...] }
    List<dynamic> items;
    if (decoded is List) {
      items = decoded;
    } else if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is List) {
        items = decoded['data'] as List;
      } else if (decoded['items'] is List) {
        items = decoded['items'] as List;
      } else {
        developer.log(
          'Unexpected JSON map structure on $url',
          name: 'WordpressService',
          error: decoded,
        );
        return [];
      }
    } else {
      developer.log(
        'Unexpected JSON type on $url',
        name: 'WordpressService',
        error: decoded.runtimeType,
      );
      return [];
    }

    final list = items.map((e) => fromJson(e as Map<String, dynamic>)).toList();

    _cache[url] = CacheEntry(list, DateTime.now());
    return list;
  }

  /// Méthode générique pour récupérer un objet unique
  Future<T?> _fetchSingle<T>(
    String url,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    if (_cache.containsKey(url)) {
      final entry = _cache[url]!;
      if (DateTime.now().difference(entry.timestamp) < _cacheDuration) {
        developer.log('Cache hit for $url', name: 'WordpressService');
        return entry.data as T;
      }
    }

    developer.log('Fetching single item from: $url', name: 'WordpressService');

    final response = await http.get(Uri.parse(url), headers: _getHeaders());

    developer.log(
      'Response status: ${response.statusCode} for $url',
      name: 'WordpressService',
    );

    if (response.statusCode != 200) {
      developer.log(
        'HTTP error ${response.statusCode} on $url',
        name: 'WordpressService',
        error: response.body,
      );
      return null;
    }

    final dynamic decoded = json.decode(response.body);

    // WP peut renvoyer une liste pour certaines requêtes filtrées
    final dynamic item = decoded is List
        ? (decoded.isNotEmpty ? decoded[0] : null)
        : decoded;

    if (item is! Map<String, dynamic>) return null;

    final parsed = fromJson(item);
    _cache[url] = CacheEntry(parsed, DateTime.now());
    return parsed;
  }
}
