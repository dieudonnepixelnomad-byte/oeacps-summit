import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:summitoeacp/data/wordpress_service.dart';
import 'package:summitoeacp/providers/language_provider.dart';
import 'package:summitoeacp/l10n/app_localizations.dart';
import '../../models/program.dart';
import '../theme/app_theme.dart';

class ProgramScreen extends StatefulWidget {
  const ProgramScreen({super.key});

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<ProgramDay>? _programDays;
  bool _isLoading = true;
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

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final lang = _lastLang ?? 'fr';
    final days = await context.read<WordpressService>().getProgram(lang: lang);
    if (mounted) {
      setState(() {
        _programDays = days;
        _isLoading = false;
        if (_tabController != null) {
          _tabController!.dispose();
        }
        _tabController = TabController(length: days.length, vsync: this);
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).currentLocale;
    final l10n = AppLocalizations(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('program_page_title')),
        bottom: _isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: SizedBox(height: 48),
              )
            : TabBar(
                controller: _tabController,
                isScrollable:
                    false, // Fixed tabs if few, scrollable if many. 3 is fine for fixed.
                indicatorColor: AppTheme.primaryColor,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.grey,
                tabs: _programDays!
                    .map((day) => Tab(text: '${day.label}\n${day.dateLabel}'))
                    .toList(),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Filter logic placeholder
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.translate('filters_simulation'))),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: _programDays!.map((day) => _buildDayList(day, l10n)).toList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Download PDF simulation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.translate('downloading_pdf')),
            ),
          );
        },
        icon: const Icon(Icons.download),
        label: Text(l10n.translate('pdf_button')),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildDayList(ProgramDay day, AppLocalizations l10n) {
    if (day.sessions.isEmpty) {
      return Center(child: Text(l10n.translate('no_session_today')));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: day.sessions.length,
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
        onTap: () => context.push('/program/session/${session.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time Column
              SizedBox(
                width: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(session.startTime),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(session.endTime),
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Content Column
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            session.locationName,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (session.speakerIds.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${session.speakerIds.length} intervenants",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Bookmark Icon
              IconButton(
                icon: Icon(
                  session.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: session.isBookmarked
                      ? AppTheme.primaryColor
                      : Colors.grey,
                ),
                onPressed: () {},
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
