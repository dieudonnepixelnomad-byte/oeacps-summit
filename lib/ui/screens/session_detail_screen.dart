/* import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_image.dart';
import '../../data/mock_repository.dart';
import '../../models/program.dart';
import '../../models/speaker.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class SessionDetailScreen extends StatefulWidget {
  final String sessionId;

  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // Note: In a real app we would fetch the single session.
    // Here we iterate to find it because our mock is simple.
    // We should ideally pass the session object or use a proper provider selector.
    // For now, let's find it.

    return FutureBuilder<List<ProgramDay>>(
      future: context.read<MockRepository>().getProgram(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        Session? session;
        for (var day in snapshot.data!) {
          try {
            session = day.sessions.firstWhere((s) => s.id == widget.sessionId);
            break;
          } catch (_) {}
        }

        if (session == null) {
          return const Scaffold(
            body: Center(child: Text("Session introuvable")),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Détail Session'),
            actions: [
              IconButton(
                icon: Icon(
                  session.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: session.isBookmarked ? AppTheme.primaryColor : null,
                ),
                onPressed: () {
                  // Toggle bookmark (local state only for now)
                  context.read<MockRepository>().toggleSessionBookmark(
                    widget.sessionId,
                  );

                  // Rebuild to show new state
                  setState(() {});

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Favoris mis à jour (simulation)"),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTypeTag(session.type),
                const SizedBox(height: 16),
                Text(
                  session.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 20,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${DateFormat('HH:mm').format(session.startTime)} - ${DateFormat('HH:mm').format(session.endTime)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      session.locationName,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'À propos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  session.description,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                if (session.speakerIds.isNotEmpty) ...[
                  const Text(
                    'Intervenants',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildSpeakersList(context, session.speakerIds),
                ],
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                // Toggle bookmark
                context.read<MockRepository>().toggleSessionBookmark(
                  widget.sessionId,
                );
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Ajouté aux favoris")),
                );
              },
              icon: Icon(
                session.isBookmarked
                    ? Icons.bookmark
                    : Icons.bookmark_add_outlined,
              ),
              label: Text(
                session.isBookmarked
                    ? "Retirer des favoris"
                    : "Ajouter aux favoris",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeTag(SessionType type) {
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSpeakersList(BuildContext context, List<String> speakerIds) {
    return FutureBuilder<List<Speaker>>(
      future: context.read<MockRepository>().getSpeakers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final speakers = snapshot.data!
            .where((s) => speakerIds.contains(s.id))
            .toList();

        return Column(
          children: speakers
              .map(
                (speaker) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipOval(
                    child: AppImage(
                      speaker.avatarUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    speaker.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${speaker.titleRole}, ${speaker.organization}',
                  ),
                  onTap: () {
                    // Navigate to speaker detail (to be implemented)
                    context.push('/speakers/detail/${speaker.id}');
                  },
                ),
              )
              .toList(),
        );
      },
    );
  }
}
 */
