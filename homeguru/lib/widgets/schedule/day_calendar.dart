import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'calendar_types.dart';
import 'calendar_data.dart';
import 'class_detail_sheet.dart';

class DayCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime today;
  final List<CalendarEvent> events;
  final Function(DateTime) onSelectDate;

  const DayCalendar({
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final days = List.generate(7, (i) => selectedDate.subtract(Duration(days: selectedDate.weekday - 1 - i)));

    final dayEvents = events.where((e) =>
      e.date.year == selectedDate.year &&
      e.date.month == selectedDate.month &&
      e.date.day == selectedDate.day
    ).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
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
                            color: isToday ? cs.primary : (isSelected ? cs.primaryContainer : Colors.transparent),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: tt.bodySmall?.copyWith(
                                color: isToday ? cs.onPrimary : (isSelected ? cs.onPrimaryContainer : cs.onSurface),
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
                      width: 60,
                      child: Column(
                        children: List.generate(24, (hour) {
                          return SizedBox(
                            height: 80,
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8, top: 4),
                                child: Text(
                                  timeLabels[hour],
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Column(
                            children: List.generate(24, (hour) {
                              return Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.15), width: 1),
                                  ),
                                ),
                              );
                            }),
                          ),
                          ...dayEvents.map((event) {
                            final top = (event.startMinutes / 60) * 80.0 + 4;
                            final height = ((event.endMinutes - event.startMinutes) / 60) * 80.0 - 8;
                            final color = _getToneColor(event.tone);

                            return Positioned(
                              top: top,
                              left: 8,
                              right: 8,
                              height: height,
                              child: GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => ClassDetailSheet(event: event),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: color, width: 1.5),
                                  ),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final h = constraints.maxHeight;
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              if (h > 40 && event.teacherImage != null) ...[
                                                CircleAvatar(
                                                  radius: 14,
                                                  backgroundImage: CachedNetworkImageProvider(event.teacherImage!),
                                                ),
                                                const SizedBox(width: 8),
                                              ],
                                              Expanded(
                                                child: Text(
                                                  event.title,
                                                  style: tt.bodyMedium?.copyWith(
                                                    color: cs.onSurface,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (h > 35 && event.teacher != null) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              event.teacher!,
                                              style: tt.labelSmall?.copyWith(
                                                color: cs.onSurfaceVariant,
                                                fontSize: 10,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                          if (h > 55 && event.meetingId != null) ...[
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Icon(Icons.videocam_rounded, size: 10, color: cs.onSurfaceVariant),
                                                const SizedBox(width: 3),
                                                Expanded(
                                                  child: Text(
                                                    event.meetingId!,
                                                    style: tt.labelSmall?.copyWith(
                                                      color: cs.onSurfaceVariant,
                                                      fontSize: 9,
                                                      fontFamily: 'monospace',
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                          if (h > 80) ...[
                                            const Spacer(),
                                            SizedBox(
                                              height: 26,
                                              child: ElevatedButton(
                                                onPressed: () {},
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: color,
                                                  foregroundColor: Colors.white,
                                                  elevation: 0,
                                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                                child: const Text('Join', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                              ),
                                            ),
                                          ],
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
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
