import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'report_stat_box.dart';
import 'report_filters.dart';

class SessionsReport extends StatefulWidget {
  final ColorScheme cs;
  final TextTheme tt;
  final Map<String, dynamic> data;

  const SessionsReport({super.key, required this.cs, required this.tt, required this.data});

  @override
  State<SessionsReport> createState() => _SessionsReportState();
}

class _SessionsReportState extends State<SessionsReport> {
  String? _selectedStudent;
  DateTimeRange? _dateRange;

  final List<String> _students = [];

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
                label: 'Total Sessions',
                value: '${widget.data['total'] ?? 0}',
                icon: Icons.event_rounded,
                cs: widget.cs,
                tt: widget.tt,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportStatBox(
                label: 'Completed',
                value: '${widget.data['completed'] ?? 0}',
                subtitle: widget.data['total'] != null && widget.data['total'] > 0
                    ? '${((widget.data['completed'] ?? 0) / widget.data['total'] * 100).toStringAsFixed(1)}%'
                    : '0%',
                icon: Icons.check_circle_rounded,
                cs: widget.cs,
                tt: widget.tt,
                highlight: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ReportStatBox(
                label: 'Cancelled',
                value: '${widget.data['cancelled'] ?? 0}',
                subtitle: widget.data['total'] != null && widget.data['total'] > 0
                    ? '${((widget.data['cancelled'] ?? 0) / widget.data['total'] * 100).toStringAsFixed(1)}%'
                    : '0%',
                icon: Icons.cancel_rounded,
                cs: widget.cs,
                tt: widget.tt,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportStatBox(
                label: 'Avg Duration',
                value: '${widget.data['avgDuration'] ?? 0} min',
                icon: Icons.timer_rounded,
                cs: widget.cs,
                tt: widget.tt,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.cs.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: widget.cs.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: [
                PieChartSectionData(
                  value: (widget.data['completed'] ?? 0).toDouble().clamp(0.01, double.infinity),
                  title: widget.data['total'] != null && widget.data['total'] > 0
                      ? '${((widget.data['completed'] ?? 0) / widget.data['total'] * 100).toStringAsFixed(0)}%'
                      : '0%',
                  color: widget.cs.tertiary,
                  radius: 50,
                  titleStyle: widget.tt.labelMedium?.copyWith(
                    color: widget.cs.onTertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                PieChartSectionData(
                  value: (widget.data['cancelled'] ?? 0).toDouble().clamp(0.01, double.infinity),
                  title: widget.data['total'] != null && widget.data['total'] > 0
                      ? '${((widget.data['cancelled'] ?? 0) / widget.data['total'] * 100).toStringAsFixed(0)}%'
                      : '0%',
                  color: widget.cs.errorContainer,
                  radius: 50,
                  titleStyle: widget.tt.labelMedium?.copyWith(
                    color: widget.cs.onErrorContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(
              color: widget.cs.tertiary,
              label: 'Completed',
              cs: widget.cs,
              tt: widget.tt,
            ),
            const SizedBox(width: 20),
            _LegendItem(
              color: widget.cs.errorContainer,
              label: 'Cancelled',
              cs: widget.cs,
              tt: widget.tt,
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final ColorScheme cs;
  final TextTheme tt;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
