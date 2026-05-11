import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'report_filters.dart';

class SubjectsReport extends StatefulWidget {
  final ColorScheme cs;
  final TextTheme tt;
  final Map<String, dynamic> data;

  const SubjectsReport({super.key, required this.cs, required this.tt, required this.data});

  @override
  State<SubjectsReport> createState() => _SubjectsReportState();
}

class _SubjectsReportState extends State<SubjectsReport> {
  DateTimeRange? _dateRange;

  List<Map<String, dynamic>> get _subjects {
    final raw = widget.data['subjects'];
    if (raw is List && raw.isNotEmpty) return raw.map((s) => Map<String, dynamic>.from(s)).toList();
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReportFilters(
          cs: widget.cs,
          tt: widget.tt,
          dateRange: _dateRange,
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
        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.cs.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: widget.cs.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 50,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => widget.cs.tertiaryContainer,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${_subjects[group.x]['name']}\n${rod.toY.toInt()} sessions',
                      widget.tt.labelSmall!.copyWith(
                        color: widget.cs.onTertiaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: widget.tt.labelSmall?.copyWith(
                          color: widget.cs.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < _subjects.length) {
                        final name = _subjects[value.toInt()]['name'] as String;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            name.split(' ').last,
                            style: widget.tt.labelSmall?.copyWith(
                              color: widget.cs.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 10,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: widget.cs.outlineVariant.withValues(alpha: 0.3),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(_subjects.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: _subjects[index]['sessions'].toDouble(),
                      color: widget.cs.tertiary,
                      width: 32,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ..._subjects.map((subject) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _SubjectRow(
            subject: subject['name'],
            sessions: subject['sessions'],
            earnings: '₹${subject['earnings']}',
            cs: widget.cs,
            tt: widget.tt,
          ),
        )),
      ],
    );
  }
}

class _SubjectRow extends StatelessWidget {
  final String subject;
  final int sessions;
  final String earnings;
  final ColorScheme cs;
  final TextTheme tt;

  const _SubjectRow({
    required this.subject,
    required this.sessions,
    required this.earnings,
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
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              subject,
              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              '$sessions sessions',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              earnings,
              style: tt.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.tertiary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
