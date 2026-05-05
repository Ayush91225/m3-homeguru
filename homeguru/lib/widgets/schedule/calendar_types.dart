enum CalendarView { day, week, month, schedule }

enum EventTone { blue, teal, violet, amber, rose }

enum SessionStatus { completed, ongoing, pending, missed }

enum MissedBy { student, teacher, both }

class CalendarFilter {
  final String id;
  final String label;
  final bool checked;
  final EventTone tone;

  const CalendarFilter({
    required this.id,
    required this.label,
    required this.checked,
    required this.tone,
  });
}

class CalendarEvent {
  final String id;
  final String title;
  final DateTime date;
  final int startMinutes;
  final int endMinutes;
  final bool allDay;
  final String calendarId;
  final EventTone tone;
  final String type;
  final String? subject;
  final String? teacher;
  final String? teacherAvatar;
  final String? teacherImage;
  final int? price;
  final bool? isTrial;
  final SessionStatus? status;
  final MissedBy? missedBy;
  final String? location;
  final String? meetingId;
  final int? sessionNumber;
  final int? totalSessions;
  final String? description;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.startMinutes,
    required this.endMinutes,
    required this.allDay,
    required this.calendarId,
    required this.tone,
    required this.type,
    this.subject,
    this.teacher,
    this.teacherAvatar,
    this.teacherImage,
    this.price,
    this.isTrial,
    this.status,
    this.missedBy,
    this.location,
    this.meetingId,
    this.sessionNumber,
    this.totalSessions,
    this.description,
  });

  CalendarEvent copyWith({
    String? id,
    String? title,
    DateTime? date,
    int? startMinutes,
    int? endMinutes,
    bool? allDay,
    String? calendarId,
    EventTone? tone,
    String? type,
    String? subject,
    String? teacher,
    String? teacherAvatar,
    String? teacherImage,
    int? price,
    bool? isTrial,
    SessionStatus? status,
    MissedBy? missedBy,
    String? location,
    String? meetingId,
    int? sessionNumber,
    int? totalSessions,
    String? description,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      allDay: allDay ?? this.allDay,
      calendarId: calendarId ?? this.calendarId,
      tone: tone ?? this.tone,
      type: type ?? this.type,
      subject: subject ?? this.subject,
      teacher: teacher ?? this.teacher,
      teacherAvatar: teacherAvatar ?? this.teacherAvatar,
      teacherImage: teacherImage ?? this.teacherImage,
      price: price ?? this.price,
      isTrial: isTrial ?? this.isTrial,
      status: status ?? this.status,
      missedBy: missedBy ?? this.missedBy,
      location: location ?? this.location,
      meetingId: meetingId ?? this.meetingId,
      sessionNumber: sessionNumber ?? this.sessionNumber,
      totalSessions: totalSessions ?? this.totalSessions,
      description: description ?? this.description,
    );
  }
}
