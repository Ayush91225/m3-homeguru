import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'report_stat_box.dart';
import 'report_filters.dart';

class EarningsReport extends StatefulWidget {
  final ColorScheme cs;
  final TextTheme tt;

  const EarningsReport({super.key, required this.cs, required this.tt});

  @override
  State<EarningsReport> createState() => _EarningsReportState();
}

class _EarningsReportState extends State<EarningsReport> {
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
                label: 'This Month',
                value: '₹45,280',
                icon: Icons.calendar_month_rounded,
                cs: widget.cs,
                tt: widget.tt,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportStatBox(
                label: 'Last Month',
                value: '₹38,950',
                icon: Icons.history_rounded,
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
                label: 'Platform Fee',
                value: '₹11,320',
                subtitle: '25% deducted',
                icon: Icons.account_balance_rounded,
                cs: widget.cs,
                tt: widget.tt,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportStatBox(
                label: 'In-Hand',
                value: '₹33,960',
                subtitle: '75% received',
                icon: Icons.account_balance_wallet_rounded,
                cs: widget.cs,
                tt: widget.tt,
                highlight: true,
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
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 10000,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: widget.cs.outlineVariant.withValues(alpha: 0.3),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '₹${(value / 1000).toStringAsFixed(0)}k',
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
                      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                      if (value.toInt() >= 0 && value.toInt() < months.length) {
                        return Text(
                          months[value.toInt()],
                          style: widget.tt.labelSmall?.copyWith(
                            color: widget.cs.onSurfaceVariant,
                            fontSize: 10,
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
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    const FlSpot(0, 32000),
                    const FlSpot(1, 35000),
                    const FlSpot(2, 38000),
                    const FlSpot(3, 36500),
                    const FlSpot(4, 38950),
                    const FlSpot(5, 45280),
                  ],
                  isCurved: true,
                  color: widget.cs.tertiary,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: widget.cs.tertiary,
                        strokeWidth: 2,
                        strokeColor: widget.cs.surface,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: widget.cs.tertiary.withValues(alpha: 0.2),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => widget.cs.tertiaryContainer,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '₹${spot.y.toStringAsFixed(0)}',
                        widget.tt.labelSmall!.copyWith(
                          color: widget.cs.onTertiaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Monthly earnings trend',
          style: widget.tt.labelSmall?.copyWith(
            color: widget.cs.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
