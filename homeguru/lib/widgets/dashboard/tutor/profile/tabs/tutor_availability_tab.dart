import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../services/tutor_profile_service.dart';
import '../../../../../screens/dashboard/tutor/profile/tutor_profile_edit_screen.dart';

class TutorAvailabilityTab extends StatefulWidget {
  const TutorAvailabilityTab({super.key, this.viewMode = false});

  final bool viewMode;

  @override
  State<TutorAvailabilityTab> createState() => _TutorAvailabilityTabState();
}

class _TutorAvailabilityTabState extends State<TutorAvailabilityTab> {
  bool _loading = true;
  Map<String, List<Map<String, String>>> _schedule = {};

  static const _dayOrder = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
  static const _dayLabels = {
    'monday': 'Monday',
    'tuesday': 'Tuesday',
    'wednesday': 'Wednesday',
    'thursday': 'Thursday',
    'friday': 'Friday',
    'saturday': 'Saturday',
    'sunday': 'Sunday',
  };

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    final prefs = await SharedPreferences.getInstance();
    final tutorId = prefs.getString('userId');
    if (tutorId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final result = await TutorProfileService.getTutorProfile(tutorId);
    if (result['success'] == true && mounted) {
      final data = result['data'] as Map<String, dynamic>;
      if (data['availability'] != null) {
        final avail = data['availability'] as Map<String, dynamic>;
        for (final day in _dayOrder) {
          if (avail[day] != null) {
            _schedule[day] = (avail[day] as List)
                .map((slot) => Map<String, String>.from(slot))
                .toList();
          } else {
            _schedule[day] = [];
          }
        }
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  String _formatTime(String time24) {
    final parts = time24.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? parts[1] : '00';
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${hour12.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (_loading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(),
      ));
    }

    final hasAnySlots = _schedule.values.any((slots) => slots.isNotEmpty);

    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        if (!widget.viewMode) ...[
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
          child: Text('Weekly Schedule', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 16),

        if (!hasAnySlots)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                Icon(Icons.calendar_today_outlined, size: 40, color: cs.onSurfaceVariant.withOpacity(0.4)),
                const SizedBox(height: 12),
                Text('No availability set', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                if (!widget.viewMode)
                  Text('Tap below to add your schedule', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          )
        else
          ..._dayOrder.map((day) => _DaySchedule(
            day: _dayLabels[day]!,
            slots: _schedule[day] ?? [],
            formatTime: _formatTime,
            cs: cs,
            tt: tt,
          )),

        if (!widget.viewMode) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: FilledButton.icon(
              onPressed: () async {
                final result = await Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const TutorProfileEditScreen(),
                ));
                if (result == true) _loadAvailability();
              },
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
    required this.formatTime,
    required this.cs,
    required this.tt,
  });
  final String day;
  final List<Map<String, String>> slots;
  final String Function(String) formatTime;
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
                          border: Border.all(color: cs.tertiary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule_rounded, size: 16, color: cs.tertiary),
                            const SizedBox(width: 8),
                            Text(
                              '${formatTime(slot['start'] ?? '')} - ${formatTime(slot['end'] ?? '')}',
                              style: tt.bodySmall?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
                  )
                : Text(
                    'Unavailable',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontStyle: FontStyle.italic),
                  ),
          ),
        ],
      ),
    );
  }
}
