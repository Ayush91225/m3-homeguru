import 'package:flutter/material.dart';
import 'report_filters.dart';

class TimeSlotsReport extends StatefulWidget {
  final ColorScheme cs;
  final TextTheme tt;

  const TimeSlotsReport({super.key, required this.cs, required this.tt});

  @override
  State<TimeSlotsReport> createState() => _TimeSlotsReportState();
}

class _TimeSlotsReportState extends State<TimeSlotsReport> {
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReportFilters(
          cs: widget.cs,
          tt: widget.tt,
          dateRange: _dateRange,
          showStudentFilter: false,
          onStudentFilterTap: () {},
          onDateFilterTap: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2024, 1, 1),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: widget.cs.copyWith(
                      primary: widget.cs.tertiary,
                      onPrimary: widget.cs.onTertiaryContainer,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() => _dateRange = picked);
            }
          },
          onClearFilters: () {
            setState(() => _dateRange = null);
          },
        ),
        _TimeSlotRow(
          timeSlot: 'Morning (6-12 PM)',
          bookings: 32,
          percentage: 25.8,
          cs: widget.cs,
          tt: widget.tt,
        ),
        const SizedBox(height: 8),
        _TimeSlotRow(
          timeSlot: 'Afternoon (12-5 PM)',
          bookings: 28,
          percentage: 22.6,
          cs: widget.cs,
          tt: widget.tt,
        ),
        const SizedBox(height: 8),
        _TimeSlotRow(
          timeSlot: 'Evening (5-9 PM)',
          bookings: 48,
          percentage: 38.7,
          highlight: true,
          cs: widget.cs,
          tt: widget.tt,
        ),
        const SizedBox(height: 8),
        _TimeSlotRow(
          timeSlot: 'Night (9-12 AM)',
          bookings: 16,
          percentage: 12.9,
          cs: widget.cs,
          tt: widget.tt,
        ),
      ],
    );
  }
}

class _TimeSlotRow extends StatelessWidget {
  final String timeSlot;
  final int bookings;
  final double percentage;
  final bool highlight;
  final ColorScheme cs;
  final TextTheme tt;

  const _TimeSlotRow({
    required this.timeSlot,
    required this.bookings,
    required this.percentage,
    this.highlight = false,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: highlight ? cs.tertiary.withValues(alpha: 0.5) : cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              timeSlot,
              style: tt.bodyMedium?.copyWith(
                fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
                color: highlight ? cs.tertiary : cs.onSurface,
              ),
            ),
          ),
          Text(
            '$bookings bookings',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: tt.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: highlight ? cs.tertiary : cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
