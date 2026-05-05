import 'package:flutter/material.dart';
import 'calendar_types.dart';
import 'class_detail_sheet.dart';

class MonthCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime today;
  final List<CalendarEvent> events;
  final Function(DateTime) onSelectDate;

  const MonthCalendar({
    super.key,
    required this.selectedDate,
    required this.today,
    required this.events,
    required this.onSelectDate,
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

  String _formatTime(int minutes) {
    final hour = minutes ~/ 60;
    final min = minutes % 60;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${min.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final startingWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    final days = <DateTime?>[];
    for (int i = 1; i < startingWeekday; i++) {
      days.add(null);
    }
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(selectedDate.year, selectedDate.month, i));
    }

    final selectedDayEvents = events.where((e) =>
      e.date.year == selectedDate.year &&
      e.date.month == selectedDate.month &&
      e.date.day == selectedDate.day
    ).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final date = days[index];
              if (date == null) {
                return const SizedBox();
              }

              final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
              final isSelected = date.year == selectedDate.year && date.month == selectedDate.month && date.day == selectedDate.day;

              final dayEvents = events.where((e) =>
                e.date.year == date.year &&
                e.date.month == date.month &&
                e.date.day == date.day
              ).toList();

              return GestureDetector(
                onTap: () => onSelectDate(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? cs.primaryContainer : (isToday ? cs.surfaceContainerHighest : Colors.transparent),
                    borderRadius: BorderRadius.circular(12),
                    border: isToday && !isSelected ? Border.all(color: cs.primary, width: 1.5) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        style: tt.bodyMedium?.copyWith(
                          color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (dayEvents.isNotEmpty)
                        Wrap(
                          spacing: 1,
                          runSpacing: 1,
                          alignment: WrapAlignment.center,
                          children: dayEvents.take(2).map((event) {
                            return Container(
                              width: 2,
                              height: 2,
                              decoration: BoxDecoration(
                                color: _getToneColor(event.tone),
                                shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            '${selectedDate.day} ${['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][selectedDate.month]}',
            style: tt.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (selectedDayEvents.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.event_busy_rounded, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.3)),
                    const SizedBox(height: 8),
                    Text(
                      'No events scheduled',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            )
          else
            ...selectedDayEvents.map((event) {
              final color = _getToneColor(event.tone);
              return GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ClassDetailSheet(event: event),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (event.subject != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                event.subject!,
                                style: tt.labelSmall?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 14, color: cs.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            '${_formatTime(event.startMinutes)} - ${_formatTime(event.endMinutes)}',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (event.teacher != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person_outline_rounded, size: 14, color: cs.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              event.teacher!,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
