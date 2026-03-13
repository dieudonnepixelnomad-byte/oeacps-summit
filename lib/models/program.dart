enum SessionType { plenary, debate, workshop, other }

class Session {
  final String id;
  final String dayId;
  final SessionType type;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String locationName;
  final List<String> speakerIds;
  bool isBookmarked;

  Session({
    required this.id,
    required this.dayId,
    required this.type,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.locationName,
    required this.speakerIds,
    this.isBookmarked = false,
  });

  Session copyWith({String? title, String? description, String? locationName}) {
    return Session(
      id: id,
      dayId: dayId,
      type: type,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime,
      endTime: endTime,
      locationName: locationName ?? this.locationName,
      speakerIds: speakerIds,
      isBookmarked: isBookmarked,
    );
  }

  factory Session.fromCustomApiJson(
    Map<String, dynamic> json, {
    String? dayDate,
  }) {
    DateTime parseTime(String? timeStr, String baseDate) {
      if (timeStr == null || timeStr.isEmpty) return DateTime.parse(baseDate);
      try {
        timeStr = timeStr.trim();
        final parts = timeStr.split(' ');
        final timeParts = parts[0].split(':');
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);

        if (parts.length > 1) {
          if (parts[1].toUpperCase() == 'PM' && hour < 12) hour += 12;
          if (parts[1].toUpperCase() == 'AM' && hour == 12) hour = 0;
        }

        final date = DateTime.parse(baseDate);
        return DateTime(date.year, date.month, date.day, hour, minute);
      } catch (e) {
        return DateTime.parse(baseDate);
      }
    }

    final baseDate = dayDate ?? DateTime.now().toIso8601String().split('T')[0];
    final String title = json['title'] ?? 'Session';

    // Infer type from title
    SessionType type = SessionType.other;
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('plénière') || lowerTitle.contains('plenary')) {
      type = SessionType.plenary;
    } else if (lowerTitle.contains('workshop') ||
        lowerTitle.contains('atelier')) {
      type = SessionType.workshop;
    } else if (lowerTitle.contains('débat') || lowerTitle.contains('debate')) {
      type = SessionType.debate;
    }

    return Session(
      id: (json.hashCode).toString(),
      dayId: baseDate,
      type: type,
      title: title,
      description: json['description'] ?? '',
      startTime: parseTime(json['start_time'], baseDate),
      endTime: parseTime(json['end_time'], baseDate),
      locationName: '', // No location in session
      speakerIds: json['speaker'] != null ? [json['speaker'].toString()] : [],
      isBookmarked: false,
    );
  }

  factory Session.fromWordpressJson(
    Map<String, dynamic> json, {
    String? dayDate,
  }) {
    // Eventin API format (from /eventin/v2/schedules -> schedule_slot)
    if (json.containsKey('etn_schedule_topic')) {
      DateTime parseTime(String? timeStr, String baseDate) {
        if (timeStr == null) return DateTime.now();
        // Time format usually "09:00 AM"
        try {
          // Parse time
          final parts = timeStr.trim().split(' ');
          if (parts.length != 2) return DateTime.parse(baseDate);

          final timeParts = parts[0].split(':');
          int hour = int.parse(timeParts[0]);
          int minute = int.parse(timeParts[1]);

          if (parts[1].toUpperCase() == 'PM' && hour < 12) hour += 12;
          if (parts[1].toUpperCase() == 'AM' && hour == 12) hour = 0;

          final date = DateTime.parse(baseDate);
          return DateTime(date.year, date.month, date.day, hour, minute);
        } catch (e) {
          return DateTime.parse(baseDate);
        }
      }

      final baseDate =
          dayDate ?? DateTime.now().toIso8601String().split('T')[0];

      return Session(
        id: (json['id'] ?? DateTime.now().millisecondsSinceEpoch)
            .toString(), // ID might be 0, 1... needs care
        dayId: baseDate,
        type: SessionType.other, // Can try to infer from topic
        title: json['etn_schedule_topic'] ?? 'Session',
        description: json['etn_shedule_objective'] ?? '',
        startTime: parseTime(json['etn_shedule_start_time'], baseDate),
        endTime: parseTime(json['etn_shedule_end_time'], baseDate),
        locationName: json['etn_shedule_room'] ?? '',
        speakerIds: [], // Not in slot directly
        isBookmarked: false,
      );
    }

    // Standard WP Format
    // Helper to safely parse dates
    DateTime parseDate(String? dateStr) {
      if (dateStr == null) return DateTime.now();
      return DateTime.tryParse(dateStr) ?? DateTime.now();
    }

    // Extract ACF fields if available, or fallbacks
    final acf = json['acf'] as Map<String, dynamic>? ?? {};

    // Map type from ACF or categories
    SessionType sessionType = SessionType.other;
    final typeStr = (acf['type'] as String?)?.toLowerCase() ?? '';
    if (typeStr.contains('pleniere')) {
      sessionType = SessionType.plenary;
    } else if (typeStr.contains('debat')) {
      sessionType = SessionType.debate;
    } else if (typeStr.contains('workshop') || typeStr.contains('atelier')) {
      sessionType = SessionType.workshop;
    }

    return Session(
      id: json['id'].toString(),
      dayId: acf['day_id']?.toString() ?? '1', // Default to day 1
      type: sessionType,
      title: json['title'] != null
          ? (json['title']['rendered'] ?? 'Session sans titre')
          : 'Session sans titre',
      description: json['content'] != null
          ? (json['content']['rendered'] ?? '')
          : '',
      startTime: parseDate(acf['start_time'] ?? json['date']),
      endTime: parseDate(acf['end_time'] ?? json['date']),
      locationName: acf['location'] ?? 'Lieu à définir',
      speakerIds: [], // Would need to parse relationships
      isBookmarked: false,
    );
  }
}

class ProgramDay {
  final String id;
  final String label;
  final String dateLabel;
  final List<Session> sessions;

  ProgramDay({
    required this.id,
    required this.label,
    required this.dateLabel,
    required this.sessions,
  });

  ProgramDay copyWith({
    String? label,
    String? dateLabel,
    List<Session>? sessions,
  }) {
    return ProgramDay(
      id: id,
      label: label ?? this.label,
      dateLabel: dateLabel ?? this.dateLabel,
      sessions: sessions ?? this.sessions,
    );
  }

  factory ProgramDay.fromEventInJson(Map<String, dynamic> json) {
    final List<dynamic> slots = json['schedule_slot'] ?? [];
    final String date = json['date'] ?? DateTime.now().toIso8601String();

    return ProgramDay(
      id: json['id'].toString(),
      label: json['program_title'] ?? 'Programme',
      dateLabel: date,
      sessions: slots
          .map((slot) => Session.fromWordpressJson(slot, dayDate: date))
          .toList(),
    );
  }

  factory ProgramDay.fromCustomApiJson(Map<String, dynamic> json) {
    final List<dynamic> sessionsJson = json['sessions'] ?? [];
    final String date =
        json['schedule_date'] ?? DateTime.now().toIso8601String();

    return ProgramDay(
      id: json['id'].toString(),
      label: json['schedule_title'] ?? 'Programme',
      dateLabel: date,
      sessions: sessionsJson
          .map((s) => Session.fromCustomApiJson(s, dayDate: date))
          .toList(),
    );
  }
}
