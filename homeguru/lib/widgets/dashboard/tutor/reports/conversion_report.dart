import 'package:flutter/material.dart';
import 'report_stat_box.dart';
import 'report_filters.dart';

class ConversionReport extends StatefulWidget {
  final ColorScheme cs;
  final TextTheme tt;

  const ConversionReport({super.key, required this.cs, required this.tt});

  @override
  State<ConversionReport> createState() => _ConversionReportState();
}

class _ConversionReportState extends State<ConversionReport> {
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
        Row(
          children: [
            Expanded(
              child: ReportStatBox(
                label: 'Demo to Paid',
                value: '68%',
                subtitle: '17/25 converted',
                icon: Icons.trending_up_rounded,
                cs: widget.cs,
                tt: widget.tt,
                highlight: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportStatBox(
                label: 'Acceptance Rate',
                value: '92%',
                subtitle: '23/25 accepted',
                icon: Icons.check_circle_rounded,
                cs: widget.cs,
                tt: widget.tt,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ReportStatBox(
                label: 'Total Requests',
                value: '25',
                icon: Icons.inbox_rounded,
                cs: widget.cs,
                tt: widget.tt,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportStatBox(
                label: 'Avg Response',
                value: '2.4 hrs',
                icon: Icons.timer_rounded,
                cs: widget.cs,
                tt: widget.tt,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
