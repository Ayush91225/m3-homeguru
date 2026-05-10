import 'package:flutter/material.dart';

class TutorAvailabilityTab extends StatelessWidget {
  const TutorAvailabilityTab({super.key, this.viewMode = false});
  
  final bool viewMode;

  static const _schedule = {
    'Monday': ['09:00 AM - 12:00 PM', '02:00 PM - 06:00 PM'],
    'Tuesday': ['09:00 AM - 12:00 PM', '02:00 PM - 06:00 PM'],
    'Wednesday': ['09:00 AM - 12:00 PM', '02:00 PM - 06:00 PM'],
    'Thursday': ['09:00 AM - 12:00 PM', '02:00 PM - 06:00 PM'],
    'Friday': ['09:00 AM - 12:00 PM', '02:00 PM - 06:00 PM'],
    'Saturday': ['10:00 AM - 04:00 PM'],
    'Sunday': [],
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        if (!viewMode) ...[
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.tertiaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.tertiary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.info_outline_rounded, color: cs.tertiary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Students can book sessions during your available time slots',
                    style: tt.bodySmall?.copyWith(color: cs.onSurface, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Weekly Schedule',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 16),
        ..._schedule.entries.map((entry) => _DaySchedule(
          day: entry.key,
          slots: List<String>.from(entry.value),
          cs: cs,
          tt: tt,
        )),
        if (!viewMode) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_calendar_rounded, size: 20),
              label: const Text('Edit Availability'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ] else
          const SizedBox(height: 32),
      ],
    );
  }
}

class _DaySchedule extends StatelessWidget {
  const _DaySchedule({
    required this.day,
    required this.slots,
    required this.cs,
    required this.tt,
  });
  final String day;
  final List<String> slots;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    final isAvailable = slots.isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 1),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              day,
              style: tt.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isAvailable ? cs.onSurface : cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: isAvailable
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: slots.map((slot) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: cs.tertiaryContainer.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: cs.tertiary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule_rounded, size: 16, color: cs.tertiary),
                            const SizedBox(width: 8),
                            Text(
                              slot,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
                  )
                : Text(
                    'Unavailable',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
