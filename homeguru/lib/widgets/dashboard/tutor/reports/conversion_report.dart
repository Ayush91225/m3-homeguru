import 'package:flutter/material.dart';
import 'report_stat_box.dart';
import 'report_filters.dart';

class ConversionReport extends StatefulWidget {
  final ColorScheme cs;
  final TextTheme tt;
  final Map<String, dynamic> data;

  const ConversionReport({super.key, required this.cs, required this.tt, required this.data});

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
                value: '${widget.data['conversionRate'] ?? 0}%',
                subtitle: '${widget.data['converted'] ?? 0}/${widget.data['totalDemos'] ?? 0} converted',
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
                value: '${widget.data['acceptanceRate'] ?? 0}%',
                subtitle: '${widget.data['accepted'] ?? 0}/${widget.data['totalRequests'] ?? 0} accepted',
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
                value: '${widget.data['totalRequests'] ?? 0}',
                icon: Icons.inbox_rounded,
                cs: widget.cs,
                tt: widget.tt,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportStatBox(
                label: 'Avg Response',
                value: '${widget.data['avgResponse'] ?? 0} hrs',
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
