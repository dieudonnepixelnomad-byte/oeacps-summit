import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:summitoeacp/data/wordpress_service.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import 'package:summitoeacp/providers/language_provider.dart';
import 'package:summitoeacp/l10n/app_localizations.dart';

import '../../models/event.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Event> _events = [];
  bool _isLoading = true;
  String _filter = 'Tous'; // Filter by period
  String? _lastLang;

  String _getProgramPdfUrl(String langCode) {
    switch (langCode) {
      case 'en':
        // TODO: Mettre le lien réel du programme en anglais
        return "https://summitoacps.com/wp-content/uploads/2026/02/Agenda-11eme-Sommet-oeacp-2026.pdf";
      case 'es':
        // TODO: Mettre le lien réel du programme en espagnol
        return "https://summitoacps.com/wp-content/uploads/2026/02/Agenda-11eme-Sommet-oeacp-2026.pdf";
      case 'fr':
      default:
        return "https://summitoacps.com/wp-content/uploads/2026/02/Agenda-11eme-Sommet-oeacp-2026.pdf";
    }
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
    developer.log('Loading events data...', name: 'EventsScreen');
    setState(() => _isLoading = true);

    final startTime = DateTime.now();

    try {
      final lang = _lastLang ?? 'fr';
      developer.log('Fetching events with lang: $lang', name: 'EventsScreen');

      final events = await context.read<WordpressService>().getEvents(
        lang: lang,
      );

      if (events.isNotEmpty) {
        final e = events[0];
        developer.log(
          'Event[0] details:\n'
          '  id: ${e.id}\n'
          '  title: ${e.title}\n'
          '  description: ${e.description}\n'
          '  startDate: ${e.startDate}\n'
          '  endDate: ${e.endDate}\n'
          '  location: ${e.location}\n'
          '  imageUrl: ${e.imageUrl}\n'
          '  program: ${e.program}',
          name: 'EventsScreen',
        );
      } else {
        developer.log('Events list is empty', name: 'EventsScreen');
      }

      final duration = DateTime.now().difference(startTime).inMilliseconds;
      developer.log(
        'Data fetch completed in ${duration}ms',
        name: 'EventsScreen',
      );

      if (!mounted) return;

      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      developer.log(
        'Error loading events',
        name: 'EventsScreen',
        error: e,
        stackTrace: stackTrace,
      );

      if (!mounted) return;

      setState(() {
        _events = [];
        _isLoading = false;
      });
    }
  }

  List<Event> _applyFilter(List<Event> events) {
    if (_filter == 'Tous') return events;

    if (_filter == 'Octobre') {
      return events.where((e) => e.startDate.month == 10).toList();
    }

    if (_filter == 'Novembre') {
      return events.where((e) => e.startDate.month == 11).toList();
    }

    return events;
  }

  Future<void> _openEventProgramPdf() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final lang = Provider.of<LanguageProvider>(
      context,
      listen: false,
    ).currentLocale;
    final l10n = AppLocalizations(lang);
    final pdfUrl = _getProgramPdfUrl(lang.languageCode);

    try {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l10n.translate('downloading_program'))),
      );

      // Récupération du dossier
      Directory? dir;
      if (Platform.isAndroid) {
        dir = await getDownloadsDirectory();
      }
      dir ??= await getApplicationDocumentsDirectory();

      final filename = "Agenda-Sommet-OEACP-2026-${lang.languageCode}.pdf";
      final file = File('${dir.path}/$filename');

      // Téléchargement
      final response = await http.get(Uri.parse(pdfUrl));

      if (response.statusCode == 200) {
        // Écriture du fichier
        await file.writeAsBytes(response.bodyBytes);

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              "${l10n.translate('download_completed')} ${dir.path}",
            ),
          ),
        );

        // Ouverture du fichier
        final result = await OpenFilex.open(file.path);
        if (result.type != ResultType.done) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                "${l10n.translate('cannot_open_file')}: ${result.message}",
              ),
            ),
          );
        }
      } else {
        throw Exception(
          '${l10n.translate('http_error')} ${response.statusCode}',
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("${l10n.translate('download_error')} ($e)")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _applyFilter(_events);
    final lang = Provider.of<LanguageProvider>(context).currentLocale;
    final l10n = AppLocalizations(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('events_page_title')),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _filter = value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'Tous',
                child: Text(l10n.translate('filter_all')),
              ),
              PopupMenuItem(
                value: 'Octobre',
                child: Text(l10n.translate('filter_oct_2025')),
              ),
              PopupMenuItem(
                value: 'Novembre',
                child: Text(l10n.translate('filter_nov_2025')),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ✅ ICI la correction : le contenu scrollable DOIT être dans Expanded/Flexible
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredEvents.isEmpty
                ? Center(child: Text(l10n.translate('no_events_found')))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      return _buildEventCard(event, l10n);
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: ElevatedButton.icon(
              onPressed: () {
                _openEventProgramPdf();
              },
              icon: const Icon(Icons.download),
              label: Text(l10n.translate('download_full_program')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event, AppLocalizations l10n) {
    // Si startDate et endDate sont le même jour, on affiche une seule date
    final isSameDay =
        event.startDate.year == event.endDate.year &&
        event.startDate.month == event.endDate.month &&
        event.startDate.day == event.endDate.day;

    final dateDisplay = isSameDay
        ? DateFormat('dd MMM yyyy').format(event.startDate)
        : '${DateFormat('dd MMM').format(event.startDate)} - ${DateFormat('dd MMM yyyy').format(event.endDate)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () => context.go('/events/detail/${event.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppImage(
              event.imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10n.translate('event_tag'),
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (event.program.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.list_alt,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${event.program.length} ${l10n.translate('days_suffix')}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dateDisplay,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.location,
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
