import 'package:flutter/material.dart';
import 'report_stat_box.dart';
import 'report_filters.dart';

class StudentsReport extends StatefulWidget {
  final ColorScheme cs;
  final TextTheme tt;
  final Map<String, dynamic> data;

  const StudentsReport({super.key, required this.cs, required this.tt, required this.data});

  @override
  State<StudentsReport> createState() => _StudentsReportState();
}

class _StudentsReportState extends State<StudentsReport> {
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
                label: 'Active Students',
                value: '${widget.data['active'] ?? 0}',
                icon: Icons.people_rounded,
                cs: widget.cs,
                tt: widget.tt,
                highlight: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportStatBox(
                label: 'New This Month',
                value: '${widget.data['newThisMonth'] ?? 0}',
                icon: Icons.person_add_rounded,
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
                label: 'Retention Rate',
                value: '${widget.data['retentionRate'] ?? 0}%',
                icon: Icons.trending_up_rounded,
                cs: widget.cs,
                tt: widget.tt,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportStatBox(
                label: 'Avg Sessions',
                value: '${widget.data['avgSessions'] ?? 0}/student',
                icon: Icons.bar_chart_rounded,
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
