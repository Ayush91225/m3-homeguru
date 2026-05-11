import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'calendar_types.dart';
import 'calendar_data.dart';
import 'week_calendar.dart';
import 'day_calendar.dart';
import 'month_calendar.dart';
import 'timezone_sheet.dart';

class CalendarApp extends StatefulWidget {
  const CalendarApp({super.key, this.isTutor = false});
  
  final bool isTutor;

  @override
  State<CalendarApp> createState() => _CalendarAppState();
}

class _CalendarAppState extends State<CalendarApp> {
  late DateTime _today;
  late DateTime _selectedDate;
  CalendarView _view = CalendarView.day;
  late List<CalendarEvent> _events;
  late List<CalendarEvent> _convertedEvents; // Cache converted events
  final List<String> _visibleCalendarIds = calendarFilters.where((c) => c.checked).map((c) => c.id).toList();
  String? _selectedFilterId;
  late String _timezone;
  String _lastConvertedTimezone = ''; // Track last conversion

  @override
  void initState() {
    super.initState();
    // Use device timezone
    try {
      _timezone = tz.local.name;
    } catch (e) {
      _timezone = 'UTC';
    }
    final location = tz.getLocation(_timezone);
    final now = tz.TZDateTime.now(location);
    _today = DateTime(now.year, now.month, now.day);
    _selectedDate = DateTime(now.year, now.month, now.day);
    _events = [];
    _convertedEvents = [];
    _lastConvertedTimezone = _timezone;
    _loadEvents(now);
  }

  Future<void> _loadEvents(tz.TZDateTime now) async {
    final events = await createInitialEvents(now, isTutor: widget.isTutor);
    if (mounted) {
      setState(() {
        _events = events;
        _convertedEvents = events;
      });
    }
  }

  void _convertEventsIfNeeded() {
    // Only convert if timezone changed
    if (_lastConvertedTimezone != _timezone) {
      final location = tz.getLocation(_timezone);
      _convertedEvents = _events.map((e) {
        final utcStart = DateTime.utc(e.date.year, e.date.month, e.date.day, e.startMinutes ~/ 60, e.startMinutes % 60);
        final tzStart = tz.TZDateTime.from(utcStart, location);
        return e.copyWith(
          date: DateTime(tzStart.year, tzStart.month, tzStart.day),
          startMinutes: tzStart.hour * 60 + tzStart.minute,
          endMinutes: tzStart.hour * 60 + tzStart.minute + (e.endMinutes - e.startMinutes),
        );
      }).toList();
      _lastConvertedTimezone = _timezone;
    }
  }

  List<CalendarEvent> get _filteredEvents {
    _convertEventsIfNeeded(); // Convert only if timezone changed
    if (_selectedFilterId != null) {
      return _convertedEvents.where((e) => e.calendarId == _selectedFilterId).toList();
    }
    return _convertedEvents.where((e) => _visibleCalendarIds.contains(e.calendarId)).toList();
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
    });
  }

  void _prev() {
    setState(() {
      if (_view == CalendarView.day) {
        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      } else if (_view == CalendarView.week) {
        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      } else {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
      }
    });
  }

  void _next() {
    setState(() {
      if (_view == CalendarView.day) {
        _selectedDate = _selectedDate.add(const Duration(days: 1));
      } else if (_view == CalendarView.week) {
        _selectedDate = _selectedDate.add(const Duration(days: 7));
      } else {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
      }
    });
  }

  String get _headerLabel {
    if (_view == CalendarView.day) {
      return '${_dayName(_selectedDate.weekday)}, ${_monthName(_selectedDate.month)} ${_selectedDate.day}';
    } else if (_view == CalendarView.week) {
      final weekStart = _startOfWeek(_selectedDate);
      final weekEnd = weekStart.add(const Duration(days: 6));
      if (weekStart.month == weekEnd.month) {
        return '${_monthName(weekStart.month)} ${weekStart.year}';
      }
      return '${_monthName(weekStart.month)} - ${_monthName(weekEnd.month)} ${weekEnd.year}';
    }
    return '${_monthName(_selectedDate.month)} ${_selectedDate.year}';
  }

  DateTime _startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  String _monthName(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
  }

  String _dayName(int weekday) {
    const days = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday];
  }

  String _getTimezoneLabel(String tz) {
    final parts = tz.split('/');
    if (parts.length > 1) {
      return parts.last.replaceAll('_', ' ');
    }
    return tz;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.calendar_month_rounded, size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  'Schedule',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                _FilterSplitButton(
                  selectedFilterId: _selectedFilterId,
                  onFilterChanged: (id) => setState(() => _selectedFilterId = id),
                ),
                const SizedBox(width: 8),
                _ViewSplitButton(
                  view: _view,
                  onViewChanged: (v) => setState(() => _view = v),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(
                top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
                bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => TimezoneSheet(
                                  currentTimezone: _timezone,
                                  onTimezoneChanged: (tzName) {
                                    setState(() {
                                      _timezone = tzName;
                                      // Update today and selected date to new timezone
                                      final location = tz.getLocation(tzName);
                                      final now = tz.TZDateTime.now(location);
                                      _today = DateTime(now.year, now.month, now.day);
                                      _selectedDate = DateTime(now.year, now.month, now.day);
                                    });
                                  },
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.public_rounded, size: 12, color: cs.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getTimezoneLabel(_timezone),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(Icons.arrow_drop_down_rounded, size: 16, color: cs.onSurfaceVariant),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _headerLabel,
                              style: tt.titleLarge?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              final location = tz.getLocation(_timezone);
                              final now = tz.TZDateTime.now(location);
                              _selectDate(DateTime(now.year, now.month, now.day));
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Text('Today', style: TextStyle(color: cs.onSurface, fontSize: 13)),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _prev,
                            icon: Icon(Icons.chevron_left_rounded, size: 24, color: cs.onSurfaceVariant),
                            style: IconButton.styleFrom(
                              backgroundColor: cs.surfaceContainerHighest,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: _next,
                            icon: Icon(Icons.chevron_right_rounded, size: 24, color: cs.onSurfaceVariant),
                            style: IconButton.styleFrom(
                              backgroundColor: cs.surfaceContainerHighest,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
                RepaintBoundary(
                  child: _view == CalendarView.day
                      ? DayCalendar(
                          selectedDate: _selectedDate,
                          today: _today,
                          events: _filteredEvents,
                          onSelectDate: _selectDate,
                          isTutor: widget.isTutor,
                        )
                      : _view == CalendarView.week
                          ? WeekCalendar(
                              weekStart: _startOfWeek(_selectedDate),
                              selectedDate: _selectedDate,
                              today: _today,
                              events: _filteredEvents,
                              onSelectDate: _selectDate,
                              isTutor: widget.isTutor,
                            )
                          : MonthCalendar(
                              selectedDate: _selectedDate,
                              today: _today,
                              events: _filteredEvents,
                              onSelectDate: _selectDate,
                              isTutor: widget.isTutor,
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSplitButton extends StatelessWidget {
  final String? selectedFilterId;
  final Function(String?) onFilterChanged;

  const _FilterSplitButton({
    required this.selectedFilterId,
    required this.onFilterChanged,
  });

  Color _getToneColor(EventTone tone) {
    switch (tone) {
      case EventTone.blue:
        return Colors.blue.shade600;
      case EventTone.teal:
        return Colors.teal.shade600;
      case EventTone.violet:
        return Colors.deepPurple.shade600;
      case EventTone.amber:
        return Colors.amber.shade700;
      case EventTone.rose:
        return Colors.pink.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selectedFilter = selectedFilterId != null
        ? calendarFilters.firstWhere((f) => f.id == selectedFilterId)
        : null;

    return SizedBox(
      height: 36,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedFilter != null) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getToneColor(selectedFilter.tone),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    selectedFilter?.label ?? 'All Subjects',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          MenuAnchor(
            builder: (context, controller, child) {
              return InkWell(
                onTap: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 20,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            },
            menuChildren: [
              MenuItemButton(
                onPressed: () => onFilterChanged(null),
                child: Row(
                  children: [
                    const SizedBox(width: 24),
                    Text('All Subjects'),
                  ],
                ),
              ),
              ...calendarFilters.map((filter) {
                return MenuItemButton(
                  onPressed: () => onFilterChanged(filter.id),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getToneColor(filter.tone),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(filter.label),
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class _ViewSplitButton extends StatelessWidget {
  final CalendarView view;
  final Function(CalendarView) onViewChanged;

  const _ViewSplitButton({
    required this.view,
    required this.onViewChanged,
  });

  String _getViewLabel(CalendarView v) {
    switch (v) {
      case CalendarView.day:
        return 'Day';
      case CalendarView.week:
        return 'Week';
      case CalendarView.month:
        return 'Month';
      case CalendarView.schedule:
        return 'Schedule';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 36,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Center(
              child: Text(
                _getViewLabel(view),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
              ),
            ),
          ),
          MenuAnchor(
            builder: (context, controller, child) {
              return InkWell(
                onTap: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 20,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            },
            menuChildren: [
              MenuItemButton(
                onPressed: () => onViewChanged(CalendarView.day),
                child: const SizedBox(width: 80, child: Text('Day')),
              ),
              MenuItemButton(
                onPressed: () => onViewChanged(CalendarView.week),
                child: const SizedBox(width: 80, child: Text('Week')),
              ),
              MenuItemButton(
                onPressed: () => onViewChanged(CalendarView.month),
                child: const SizedBox(width: 80, child: Text('Month')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
