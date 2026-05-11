import 'package:flutter/material.dart';
import '../../../../services/tutor_data_model.dart';

class TimeSlotsReport extends StatelessWidget {
  final ColorScheme cs;
  final TextTheme tt;
  final Map<String, dynamic> data;

  const TimeSlotsReport({super.key, required this.cs, required this.tt, required this.data});

  static const _dayOrder = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
  static const _dayLabels = {'monday': 'Mon', 'tuesday': 'Tue', 'wednesday': 'Wed', 'thursday': 'Thu', 'friday': 'Fri', 'saturday': 'Sat', 'sunday': 'Sun'};

  @override
  Widget build(BuildContext context) {
    final availability = TutorData.of(context).availability;
    final totalSlots = _dayOrder.fold<int>(0, (s, d) => s + availability[d]!.length);

    if (totalSlots == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Column(children: [
          Icon(Icons.schedule_outlined, size: 36, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 8),
          Text('No availability set', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        ]),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text('$totalSlots slots across ${_dayOrder.where((d) => availability[d]!.isNotEmpty).length} days',
            style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
        ),
        ..._dayOrder.where((d) => availability[d]!.isNotEmpty).map((day) {
          final slots = availability[day]!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_dayLabels[day]!, style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: cs.tertiary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: slots.map((slot) {
                      final start = slot['start'] ?? '';
                      final end = slot['end'] ?? '';
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: cs.tertiaryContainer.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('$start – $end', style: tt.labelSmall?.copyWith(color: cs.onTertiaryContainer, fontWeight: FontWeight.w500)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
