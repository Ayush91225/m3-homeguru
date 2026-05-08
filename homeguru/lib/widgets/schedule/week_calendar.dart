import 'package:flutter/material.dart';
import 'calendar_types.dart';
import 'calendar_data.dart';
import 'class_detail_sheet.dart';

class WeekCalendar extends StatelessWidget {
  final DateTime weekStart;
  final DateTime selectedDate;
  final DateTime today;
  final List<CalendarEvent> events;
  final Function(DateTime) onSelectDate;
  final bool isTutor;

  const WeekCalendar({
    super.key,
    required this.weekStart,
    required this.selectedDate,
    required this.today,
    required this.events,
    required this.onSelectDate,
    this.isTutor = false,
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
    final tt = Theme.of(context).textTheme;
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
          ),
          child: Row(
            children: [
              const SizedBox(width: 48),
              ...days.map((day) {
                final isToday = day.year == today.year && day.month == today.month && day.day == today.day;
                final isSelected = day.year == selectedDate.year && day.month == selectedDate.month && day.day == selectedDate.day;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onSelectDate(day),
                    child: Column(
                      children: [
                        Text(
                          ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day.weekday - 1],
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isToday
                                ? (isTutor ? cs.tertiary : cs.primary)
                                : (isSelected
                                    ? (isTutor ? cs.tertiaryContainer : cs.primaryContainer)
                                    : Colors.transparent),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: tt.bodySmall?.copyWith(
                                color: isToday
                                    ? (isTutor ? cs.onTertiary : cs.onPrimary)
                                    : (isSelected
                                        ? (isTutor ? cs.onTertiaryContainer : cs.onPrimaryContainer)
                                        : cs.onSurface),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        SizedBox(
          height: 600,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 48,
                      child: Column(
                        children: List.generate(24, (hour) {
                          return SizedBox(
                            height: 60,
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 6, top: 4),
                                child: Text(
                                  timeLabels[hour],
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    ...days.map((day) {
                      final dayEvents = events.where((e) =>
                        e.date.year == day.year &&
                        e.date.month == day.month &&
                        e.date.day == day.day
                      ).toList();

                      return Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.15), width: 1),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Column(
                                children: List.generate(24, (hour) {
                                  return Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.15), width: 1),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              ...dayEvents.map((event) {
                                final top = (event.startMinutes / 60) * 60.0 + 3;
                                final height = ((event.endMinutes - event.startMinutes) / 60) * 60.0 - 6;
                                final color = isTutor ? cs.tertiary : _getToneColor(event.tone);

                                return Positioned(
                                  top: top,
                                  left: 2,
                                  right: 2,
                                  height: height,
                                  child: GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) => ClassDetailSheet(event: event, isTutor: isTutor),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: color, width: 2),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            event.title,
                                            style: tt.labelSmall?.copyWith(
                                              color: cs.onSurface,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (height > 30 && event.teacher != null) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              event.teacher!,
                                              style: tt.labelSmall?.copyWith(
                                                color: cs.onSurfaceVariant,
                                                fontSize: 8,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
