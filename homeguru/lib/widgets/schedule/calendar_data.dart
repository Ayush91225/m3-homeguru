import 'package:timezone/timezone.dart' as tz;
import 'calendar_types.dart';
import '../../services/session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const calendarFilters = [
  CalendarFilter(id: 'science', label: 'Science', checked: true, tone: EventTone.blue),
  CalendarFilter(id: 'humanities', label: 'Humanities', checked: true, tone: EventTone.teal),
  CalendarFilter(id: 'maths', label: 'Mathematics', checked: true, tone: EventTone.violet),
  CalendarFilter(id: 'arts', label: 'Arts & PE', checked: true, tone: EventTone.amber),
  CalendarFilter(id: 'language', label: 'Language', checked: true, tone: EventTone.rose),
];

const timeLabels = [
  '12 AM', '1 AM', '2 AM', '3 AM', '4 AM', '5 AM', '6 AM', '7 AM', '8 AM', '9 AM', '10 AM', '11 AM',
  '12 PM', '1 PM', '2 PM', '3 PM', '4 PM', '5 PM', '6 PM', '7 PM', '8 PM', '9 PM', '10 PM', '11 PM',
];

Future<List<CalendarEvent>> createInitialEvents(tz.TZDateTime anchorDate, {bool isTutor = false}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return [];

    final sessions = await SessionService.fetchSessions(
      tutorId: isTutor ? userId : null,
      learnerId: isTutor ? null : userId,
    );

    return sessions.map((s) {
      final scheduledAt = DateTime.tryParse(s['scheduledAt']?.toString() ?? '') ?? DateTime.now();
      final duration = s['duration'] as int? ?? 60;
      final startMinutes = scheduledAt.hour * 60 + scheduledAt.minute;
      final endMinutes = startMinutes + duration;

      final subject = s['subject']?.toString() ?? '';
      final calendarId = _getCalendarId(subject);
      final tone = _getTone(calendarId);

      final status = s['status']?.toString() ?? 'upcoming';
      final sessionStatus = status == 'conducted' 
          ? SessionStatus.completed 
          : status == 'ongoing'
              ? SessionStatus.ongoing
              : SessionStatus.pending;

      return CalendarEvent(
        id: s['sessionId']?.toString() ?? '',
        title: s['subject']?.toString() ?? 'Session',
        date: DateTime(scheduledAt.year, scheduledAt.month, scheduledAt.day),
        startMinutes: startMinutes,
        endMinutes: endMinutes,
        allDay: false,
        calendarId: calendarId,
        tone: tone,
        type: s['type']?.toString() ?? 'demo',
        subject: subject,
        teacher: isTutor ? s['learnerName']?.toString() : s['tutorName']?.toString(),
        teacherImage: isTutor ? s['learnerImage']?.toString() : s['tutorImage']?.toString(),
        price: s['price'] as int?,
        isTrial: s['type'] == 'demo',
        status: sessionStatus,
        meetingId: s['meetingId']?.toString(),
        sessionNumber: s['sessionNumber'] as int?,
        totalSessions: s['totalSessions'] as int?,
      );
    }).toList();
  } catch (e) {
    print('Error loading calendar events: $e');
    return [];
  }
}

String _getCalendarId(String subject) {
  final lower = subject.toLowerCase();
  if (lower.contains('science') || lower.contains('physics') || lower.contains('chemistry') || lower.contains('biology')) {
    return 'science';
  } else if (lower.contains('math')) {
    return 'maths';
  } else if (lower.contains('history') || lower.contains('geography') || lower.contains('social')) {
    return 'humanities';
  } else if (lower.contains('art') || lower.contains('pe') || lower.contains('physical')) {
    return 'arts';
  } else if (lower.contains('english') || lower.contains('hindi') || lower.contains('language')) {
    return 'language';
  }
  return 'science';
}

EventTone _getTone(String calendarId) {
  switch (calendarId) {
    case 'science':
      return EventTone.blue;
    case 'humanities':
      return EventTone.teal;
    case 'maths':
      return EventTone.violet;
    case 'arts':
      return EventTone.amber;
    case 'language':
      return EventTone.rose;
    default:
      return EventTone.blue;
  }
}


