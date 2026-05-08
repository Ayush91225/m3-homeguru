import 'package:timezone/timezone.dart' as tz;
import 'calendar_types.dart';

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

List<CalendarEvent> createInitialEvents(tz.TZDateTime anchorDate, {bool isTutor = false}) {
  final events = <CalendarEvent>[];
  final weeklyTemplate = isTutor ? _tutorWeeklyTemplate : _learnerWeeklyTemplate;

  for (int w = -4; w <= 4; w++) {
    final weekStart = _startOfWeek(anchorDate.add(Duration(days: w * 7)));
    for (final cls in weeklyTemplate) {
      final localDay = weekStart.add(Duration(days: cls['day'] as int));
      final localTime = tz.TZDateTime(
        anchorDate.location,
        localDay.year,
        localDay.month,
        localDay.day,
        (cls['start'] as int) ~/ 60,
        (cls['start'] as int) % 60,
      );
      final utcTime = localTime.toUtc();
      
      events.add(CalendarEvent(
        id: 'cls-w$w-${cls['id']}',
        title: cls['title'] as String,
        subject: cls['subject'] as String,
        teacher: cls['teacher'] as String,
        teacherImage: cls['teacherImage'] as String?,
        price: cls['price'] as int,
        isTrial: cls['isTrial'] as bool,
        date: DateTime.utc(utcTime.year, utcTime.month, utcTime.day),
        startMinutes: utcTime.hour * 60 + utcTime.minute,
        endMinutes: utcTime.hour * 60 + utcTime.minute + ((cls['end'] as int) - (cls['start'] as int)),
        allDay: false,
        calendarId: cls['calendarId'] as String,
        tone: cls['tone'] as EventTone,
        type: 'event',
        meetingId: cls['meetingId'] as String?,
        sessionNumber: cls['sessionNumber'] as int?,
        totalSessions: cls['totalSessions'] as int?,
      ));
    }
  }
  return events;
}

final _learnerWeeklyTemplate = [
    {'day': 1, 'id': 'mon-1', 'title': 'Mathematics', 'subject': 'Mathematics', 'teacher': 'Mr. Arjun Sharma', 'teacherImage': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400', 'start': 8 * 60, 'end': 9 * 60, 'calendarId': 'maths', 'tone': EventTone.violet, 'meetingId': 'MTH-8901-2345', 'sessionNumber': 12, 'totalSessions': 100, 'price': 499, 'isTrial': false},
    {'day': 1, 'id': 'mon-2', 'title': 'Physics', 'subject': 'Physics', 'teacher': 'Ms. Priya Nair', 'teacherImage': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400', 'start': 9 * 60, 'end': 10 * 60, 'calendarId': 'science', 'tone': EventTone.blue, 'meetingId': 'PHY-5678-9012', 'sessionNumber': 8, 'totalSessions': 50, 'price': 599, 'isTrial': false},
    {'day': 1, 'id': 'mon-3', 'title': 'English Literature', 'subject': 'English', 'teacher': 'Mrs. Sunita Verma', 'teacherImage': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400', 'start': 11 * 60, 'end': 12 * 60, 'calendarId': 'language', 'tone': EventTone.rose, 'meetingId': 'ENG-3456-7890', 'sessionNumber': 1, 'totalSessions': 1, 'price': 0, 'isTrial': true},
    {'day': 2, 'id': 'tue-1', 'title': 'Chemistry', 'subject': 'Chemistry', 'teacher': 'Ms. Anita Desai', 'teacherImage': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400', 'start': 8 * 60, 'end': 9 * 60, 'calendarId': 'science', 'tone': EventTone.blue, 'meetingId': 'CHM-1234-5678', 'sessionNumber': 15, 'totalSessions': 60, 'price': 599, 'isTrial': false},
    {'day': 2, 'id': 'tue-2', 'title': 'Mathematics', 'subject': 'Mathematics', 'teacher': 'Mr. Arjun Sharma', 'teacherImage': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400', 'start': 9 * 60, 'end': 10 * 60, 'calendarId': 'maths', 'tone': EventTone.violet, 'meetingId': 'MTH-8901-2345', 'sessionNumber': 13, 'totalSessions': 100, 'price': 499, 'isTrial': false},
    {'day': 3, 'id': 'wed-1', 'title': 'Biology', 'subject': 'Biology', 'teacher': 'Dr. Neha Gupta', 'teacherImage': 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=400', 'start': 8 * 60, 'end': 9 * 60, 'calendarId': 'science', 'tone': EventTone.blue, 'meetingId': 'BIO-9012-3456', 'sessionNumber': 20, 'totalSessions': 75, 'price': 549, 'isTrial': false},
    {'day': 3, 'id': 'wed-2', 'title': 'English Literature', 'subject': 'English', 'teacher': 'Mrs. Sunita Verma', 'teacherImage': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400', 'start': 9 * 60, 'end': 10 * 60, 'calendarId': 'language', 'tone': EventTone.rose, 'meetingId': 'ENG-7890-1234', 'sessionNumber': 5, 'totalSessions': 40, 'price': 399, 'isTrial': false},
    {'day': 4, 'id': 'thu-1', 'title': 'Physics', 'subject': 'Physics', 'teacher': 'Ms. Priya Nair', 'teacherImage': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400', 'start': 8 * 60, 'end': 9 * 60, 'calendarId': 'science', 'tone': EventTone.blue, 'meetingId': 'PHY-5678-9012', 'sessionNumber': 9, 'totalSessions': 50, 'price': 599, 'isTrial': false},
    {'day': 4, 'id': 'thu-2', 'title': 'History', 'subject': 'History', 'teacher': 'Mr. Ravi Kulkarni', 'teacherImage': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400', 'start': 9 * 60, 'end': 10 * 60, 'calendarId': 'humanities', 'tone': EventTone.teal, 'meetingId': 'HIS-2345-6789', 'sessionNumber': 3, 'totalSessions': 30, 'price': 399, 'isTrial': false},
    {'day': 5, 'id': 'fri-1', 'title': 'Biology', 'subject': 'Biology', 'teacher': 'Dr. Neha Gupta', 'teacherImage': 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=400', 'start': 8 * 60, 'end': 9 * 60, 'calendarId': 'science', 'tone': EventTone.blue, 'meetingId': 'BIO-9012-3456', 'sessionNumber': 21, 'totalSessions': 75, 'price': 549, 'isTrial': false},
    {'day': 5, 'id': 'fri-2', 'title': 'Mathematics', 'subject': 'Mathematics', 'teacher': 'Mr. Arjun Sharma', 'teacherImage': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400', 'start': 14 * 60, 'end': 15 * 60, 'calendarId': 'maths', 'tone': EventTone.violet, 'meetingId': 'MTH-8901-2345', 'sessionNumber': 14, 'totalSessions': 100, 'price': 499, 'isTrial': false},
];

final _tutorWeeklyTemplate = [
  {'day': 1, 'id': 'mon-1', 'title': 'Aarav Kumar - JEE Maths', 'subject': 'Mathematics', 'teacher': 'Aarav Kumar', 'teacherImage': 'https://i.pravatar.cc/150?img=33', 'start': 8 * 60, 'end': 9 * 60, 'calendarId': 'maths', 'tone': EventTone.violet, 'meetingId': 'MTH-8901-2345', 'sessionNumber': 12, 'totalSessions': 100, 'price': 499, 'isTrial': false},
  {'day': 1, 'id': 'mon-2', 'title': 'Diya Patel - Class 10 Physics', 'subject': 'Physics', 'teacher': 'Diya Patel', 'teacherImage': 'https://i.pravatar.cc/150?img=45', 'start': 9 * 60, 'end': 10 * 60, 'calendarId': 'science', 'tone': EventTone.blue, 'meetingId': 'PHY-5678-9012', 'sessionNumber': 8, 'totalSessions': 50, 'price': 599, 'isTrial': false},
  {'day': 1, 'id': 'mon-3', 'title': 'Rohan Singh - NEET Chemistry', 'subject': 'Chemistry', 'teacher': 'Rohan Singh', 'teacherImage': 'https://i.pravatar.cc/150?img=51', 'start': 11 * 60, 'end': 12 * 60, 'calendarId': 'science', 'tone': EventTone.blue, 'meetingId': 'CHM-3456-7890', 'sessionNumber': 1, 'totalSessions': 1, 'price': 0, 'isTrial': true},
  {'day': 2, 'id': 'tue-1', 'title': 'Ananya Reddy - Class 9 Maths', 'subject': 'Mathematics', 'teacher': 'Ananya Reddy', 'teacherImage': 'https://i.pravatar.cc/150?img=26', 'start': 8 * 60, 'end': 9 * 60, 'calendarId': 'maths', 'tone': EventTone.violet, 'meetingId': 'MTH-1234-5678', 'sessionNumber': 15, 'totalSessions': 60, 'price': 399, 'isTrial': false},
  {'day': 2, 'id': 'tue-2', 'title': 'Aarav Kumar - JEE Maths', 'subject': 'Mathematics', 'teacher': 'Aarav Kumar', 'teacherImage': 'https://i.pravatar.cc/150?img=33', 'start': 9 * 60, 'end': 10 * 60, 'calendarId': 'maths', 'tone': EventTone.violet, 'meetingId': 'MTH-8901-2345', 'sessionNumber': 13, 'totalSessions': 100, 'price': 499, 'isTrial': false},
  {'day': 3, 'id': 'wed-1', 'title': 'Diya Patel - Class 10 Physics', 'subject': 'Physics', 'teacher': 'Diya Patel', 'teacherImage': 'https://i.pravatar.cc/150?img=45', 'start': 8 * 60, 'end': 9 * 60, 'calendarId': 'science', 'tone': EventTone.blue, 'meetingId': 'PHY-5678-9012', 'sessionNumber': 9, 'totalSessions': 50, 'price': 599, 'isTrial': false},
  {'day': 3, 'id': 'wed-2', 'title': 'Ishaan Sharma - Class 12 English', 'subject': 'English', 'teacher': 'Ishaan Sharma', 'teacherImage': 'https://i.pravatar.cc/150?img=60', 'start': 9 * 60, 'end': 10 * 60, 'calendarId': 'language', 'tone': EventTone.rose, 'meetingId': 'ENG-7890-1234', 'sessionNumber': 5, 'totalSessions': 40, 'price': 399, 'isTrial': false},
  {'day': 4, 'id': 'thu-1', 'title': 'Rohan Singh - NEET Chemistry', 'subject': 'Chemistry', 'teacher': 'Rohan Singh', 'teacherImage': 'https://i.pravatar.cc/150?img=51', 'start': 8 * 60, 'end': 9 * 60, 'calendarId': 'science', 'tone': EventTone.blue, 'meetingId': 'CHM-3456-7890', 'sessionNumber': 2, 'totalSessions': 60, 'price': 599, 'isTrial': false},
  {'day': 4, 'id': 'thu-2', 'title': 'Kavya Menon - Class 8 History', 'subject': 'History', 'teacher': 'Kavya Menon', 'teacherImage': 'https://i.pravatar.cc/150?img=29', 'start': 9 * 60, 'end': 10 * 60, 'calendarId': 'humanities', 'tone': EventTone.teal, 'meetingId': 'HIS-2345-6789', 'sessionNumber': 3, 'totalSessions': 30, 'price': 299, 'isTrial': false},
  {'day': 5, 'id': 'fri-1', 'title': 'Ananya Reddy - Class 9 Maths', 'subject': 'Mathematics', 'teacher': 'Ananya Reddy', 'teacherImage': 'https://i.pravatar.cc/150?img=26', 'start': 8 * 60, 'end': 9 * 60, 'calendarId': 'maths', 'tone': EventTone.violet, 'meetingId': 'MTH-1234-5678', 'sessionNumber': 16, 'totalSessions': 60, 'price': 399, 'isTrial': false},
  {'day': 5, 'id': 'fri-2', 'title': 'Aarav Kumar - JEE Maths', 'subject': 'Mathematics', 'teacher': 'Aarav Kumar', 'teacherImage': 'https://i.pravatar.cc/150?img=33', 'start': 14 * 60, 'end': 15 * 60, 'calendarId': 'maths', 'tone': EventTone.violet, 'meetingId': 'MTH-8901-2345', 'sessionNumber': 14, 'totalSessions': 100, 'price': 499, 'isTrial': false},
];

DateTime _startOfWeek(tz.TZDateTime date) {
  return date.subtract(Duration(days: date.weekday - 1));
}
