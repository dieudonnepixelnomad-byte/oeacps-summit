import 'dart:developer' as developer show log;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:summitoeacp/data/wordpress_service.dart';
import 'package:summitoeacp/providers/language_provider.dart';
import 'package:summitoeacp/l10n/app_localizations.dart';
import '../../models/event.dart';
import '../../models/program.dart';
import '../../models/speaker.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with TickerProviderStateMixin {
  Event? _event;
  List<Speaker> _allSpeakers = [];
  bool _isLoading = true;

  TabController? _tabController;
  String? _lastLang;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = Provider.of<LanguageProvider>(context).currentLanguageCode;
    if (_lastLang != lang) {
      _lastLang = lang;
      _loadData();
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final repo = context.read<WordpressService>();
    final lang = _lastLang ?? 'fr';

    // ✅ Ton service attend String ou int selon ta version.
    // Ici tu m'as montré un appel avec int.parse(widget.eventId).
    final event = await repo.getEvent(int.parse(widget.eventId), lang: lang);

    // Si tu veux tout passer par custom API, on retirera ce getSpeakers() global après.
    final speakers = await repo.getSpeakers(lang: lang);

    developer.log('Event Response: $event');
    developer.log('Speakers Response: $speakers');

    if (!mounted) return;

    // ✅ Rebuild TabController proprement
    _tabController?.dispose();
    _tabController = null;

    final programLength = event?.program.length ?? 0;
    if (programLength > 0) {
      _tabController = TabController(length: programLength, vsync: this);
    }

    setState(() {
      _event = event;
      _allSpeakers = speakers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).currentLocale;
    final l10n = AppLocalizations(lang);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_event == null) {
      return Scaffold(
        body: Center(child: Text(l10n.translate('event_not_found'))),
      );
    }

    final event = _event!;

    // ✅ Description robuste :
    // - si ton API te renvoie du HTML => HtmlWidget ok
    // - si ton API te renvoie du texte => HtmlWidget l’affichera aussi
    final description = (event.description).trim();

    final hasProgram = event.program.isNotEmpty && _tabController != null;
    final hasSpeakers =
        event.speakerIds.isNotEmpty || event.embeddedSpeakers.isNotEmpty;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              actions: [
                IconButton(icon: const Icon(Icons.share), onPressed: () {}),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                  ),
                  textScaler: const TextScaler.linear(0.8),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImage(event.imageUrl, fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ✅ Bloc infos (header)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date & Location
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Builder(
                          builder: (context) {
                            final isSameDay =
                                event.startDate.year == event.endDate.year &&
                                event.startDate.month == event.endDate.month &&
                                event.startDate.day == event.endDate.day;

                            final dateDisplay = isSameDay
                                ? DateFormat('dd MMM yyyy', lang.toString())
                                    .format(event.startDate)
                                : '${DateFormat('dd MMM', lang.toString()).format(event.startDate)} - ${DateFormat('dd MMM yyyy', lang.toString()).format(event.endDate)}';

                            return Text(
                              dateDisplay,
                              style: const TextStyle(fontSize: 16),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.location,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    Text(
                      l10n.translate('about_label'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (description.isEmpty)
                      Text(
                        l10n.translate('desc_coming_soon'),
                        style: const TextStyle(color: Colors.grey),
                      )
                    else
                      HtmlWidget(
                        description,
                        textStyle: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    const SizedBox(height: 24),

                    // Speakers section
                    if (hasSpeakers) ...[
                      Text(
                        l10n.translate('speakers_label'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSpeakersList(),
                      const SizedBox(height: 24),
                    ],

                    // ✅ On évite de mettre "Programme" ici si on n'a pas de programme
                    if (hasProgram)
                      Text(
                        l10n.translate('program_label'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ✅ TabBar sticky seulement si programme
            if (hasProgram)
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppTheme.primaryColor,
                    tabs: event.program
                        .map(
                          (day) => Tab(text: '${day.label}\n${day.dateLabel}'),
                        )
                        .toList(),
                  ),
                ),
                pinned: true,
              ),
          ];
        },

        // ✅ BODY du NestedScrollView :
        // Ici il ne doit y avoir qu’un scroll principal stable.
        body: !hasProgram
            ? Center(child: Text(l10n.translate('program_coming_soon')))
            : TabBarView(
                controller: _tabController,
                children: event.program
                    .map((day) => _buildDayList(day))
                    .toList(),
              ),
      ),
    );
  }

  Widget _buildSpeakersList() {
    // ✅ On construit la liste des speakers de l’event
    List<Speaker> eventSpeakers = [];

    // 1) chercher dans la liste globale (plus détaillée)
    if (_allSpeakers.isNotEmpty && _event != null) {
      eventSpeakers = _allSpeakers
          .where((s) => _event!.speakerIds.contains(s.id))
          .toList();
    }

    // 2) fallback sur embeddedSpeakers
    if (eventSpeakers.isEmpty && _event!.embeddedSpeakers.isNotEmpty) {
      eventSpeakers = _event!.embeddedSpeakers;
    }

    if (eventSpeakers.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: eventSpeakers.length,
        itemBuilder: (context, index) {
          final speaker = eventSpeakers[index];

          final ImageProvider avatarProvider =
              speaker.avatarUrl.startsWith('http')
              ? NetworkImage(speaker.avatarUrl)
              : AssetImage(speaker.avatarUrl);

          return Container(
            width: 90,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: avatarProvider,
                  onBackgroundImageError: (_, __) {},
                ),
                const SizedBox(height: 8),
                Text(
                  speaker.fullName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayList(ProgramDay day) {
    if (day.sessions.isEmpty) {
      return const Center(child: Text("Aucune session ce jour."));
    }

    // ✅ Fix important :
    // - primary:false empêche ce ListView de se battre avec le NestedScrollView
    // - physics: ClampingScrollPhysics pour un scroll fluide
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: day.sessions.length,
      primary: false,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        final session = day.sessions[index];
        return _buildSessionCard(session);
      },
    );
  }

  Widget _buildSessionCard(Session session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.go(
          '/events/detail/${widget.eventId}/session/${session.id}',
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time column
              SizedBox(
                width: 50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(session.startTime),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(session.endTime),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Content column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeChip(session.type),
                    const SizedBox(height: 8),
                    Text(
                      session.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Location
                    if (session.locationName.trim().isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              session.locationName,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
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
      ),
    );
  }

  Widget _buildTypeChip(SessionType type) {
    Color color;
    String label;

    switch (type) {
      case SessionType.plenary:
        color = Colors.blue;
        label = "Plénière";
        break;
      case SessionType.workshop:
        color = Colors.orange;
        label = "Workshop";
        break;
      case SessionType.debate:
        color = Colors.purple;
        label = "Débat";
        break;
      default:
        color = Colors.grey;
        label = "Autre";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
