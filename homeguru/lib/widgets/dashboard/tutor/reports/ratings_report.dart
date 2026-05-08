import 'package:flutter/material.dart';
import 'report_stat_box.dart';
import 'report_filters.dart';

class RatingsReport extends StatefulWidget {
  final ColorScheme cs;
  final TextTheme tt;

  const RatingsReport({super.key, required this.cs, required this.tt});

  @override
  State<RatingsReport> createState() => _RatingsReportState();
}

class _RatingsReportState extends State<RatingsReport> {
  String? _selectedStudent;
  DateTimeRange? _dateRange;

  final List<String> _students = ['Aarav Kumar', 'Diya Sharma', 'Arjun Patel', 'Ananya Singh', 'Rohan Mehta'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReportFilters(
          cs: widget.cs,
          tt: widget.tt,
          selectedStudent: _selectedStudent,
          dateRange: _dateRange,
          studentsList: _students,
          onStudentFilterTap: () async {
            final selected = await showModalBottomSheet<String>(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => Container(
                decoration: BoxDecoration(
                  color: widget.cs.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: widget.cs.onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Select Student', style: widget.tt.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 20),
                    ..._students.map((student) => ListTile(
                      title: Text(student),
                      selected: _selectedStudent == student,
                      selectedTileColor: widget.cs.tertiaryContainer.withValues(alpha: 0.3),
                      onTap: () => Navigator.pop(context, student),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    )),
                  ],
                ),
              ),
            );
            if (selected != null) {
              setState(() => _selectedStudent = selected);
            }
          },
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
            setState(() {
              _selectedStudent = null;
              _dateRange = null;
            });
          },
        ),
        Row(
          children: [
            Expanded(
              child: ReportStatBox(
                label: 'Average Rating',
                value: '4.8',
                icon: Icons.star_rounded,
                cs: widget.cs,
                tt: widget.tt,
                highlight: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportStatBox(
                label: 'Total Reviews',
                value: '156',
                icon: Icons.rate_review_rounded,
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
                label: '5 Star',
                value: '128',
                subtitle: '82.1%',
                icon: Icons.star_rounded,
                cs: widget.cs,
                tt: widget.tt,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportStatBox(
                label: '4 Star',
                value: '24',
                subtitle: '15.4%',
                icon: Icons.star_half_rounded,
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
