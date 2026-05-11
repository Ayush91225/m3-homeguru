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
  // No hardcoded events — calendar shows empty until real schedule API is available
  return <CalendarEvent>[];
}


