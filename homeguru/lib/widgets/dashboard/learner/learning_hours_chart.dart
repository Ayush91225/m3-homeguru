import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LearningHoursChart extends StatefulWidget {
  const LearningHoursChart({super.key});

  @override
  State<LearningHoursChart> createState() => _LearningHoursChartState();
}

class _LearningHoursChartState extends State<LearningHoursChart> {
  String _selectedPeriod = '7d';

  final Map<String, List<FlSpot>> _chartData = {
    '7d': [
      const FlSpot(0, 2.5),
      const FlSpot(1, 3.2),
      const FlSpot(2, 1.8),
      const FlSpot(3, 4.5),
      const FlSpot(4, 3.8),
      const FlSpot(5, 5.2),
      const FlSpot(6, 4.1),
    ],
    '30d': [
      const FlSpot(0, 3.2),
      const FlSpot(1, 2.8),
      const FlSpot(2, 4.5),
      const FlSpot(3, 3.8),
      const FlSpot(4, 5.2),
      const FlSpot(5, 4.1),
      const FlSpot(6, 3.5),
      const FlSpot(7, 4.8),
      const FlSpot(8, 3.2),
      const FlSpot(9, 5.5),
      const FlSpot(10, 4.2),
      const FlSpot(11, 3.8),
      const FlSpot(12, 5.0),
      const FlSpot(13, 4.5),
      const FlSpot(14, 3.9),
    ],
    '90d': [
      const FlSpot(0, 2.8),
      const FlSpot(1, 3.5),
      const FlSpot(2, 4.2),
      const FlSpot(3, 3.8),
      const FlSpot(4, 4.8),
      const FlSpot(5, 3.2),
      const FlSpot(6, 5.2),
      const FlSpot(7, 4.5),
      const FlSpot(8, 3.8),
      const FlSpot(9, 4.9),
      const FlSpot(10, 3.5),
      const FlSpot(11, 5.5),
      const FlSpot(12, 4.2),
      const FlSpot(13, 3.9),
      const FlSpot(14, 5.0),
      const FlSpot(15, 4.3),
      const FlSpot(16, 3.7),
      const FlSpot(17, 4.8),
      const FlSpot(18, 5.2),
      const FlSpot(19, 4.1),
      const FlSpot(20, 3.6),
      const FlSpot(21, 4.7),
      const FlSpot(22, 5.3),
      const FlSpot(23, 4.4),
      const FlSpot(24, 3.8),
      const FlSpot(25, 5.1),
      const FlSpot(26, 4.6),
      const FlSpot(27, 3.9),
      const FlSpot(28, 4.5),
      const FlSpot(29, 5.0),
    ],
  };

  List<String> _getDateLabels() {
    final now = DateTime.now();
    final dataPoints = _chartData[_selectedPeriod]!.length;
    
    if (_selectedPeriod == '7d') {
      return List.generate(dataPoints, (i) {
        final date = now.subtract(Duration(days: dataPoints - 1 - i));
        return '${date.month}/${date.day}';
      });
    } else if (_selectedPeriod == '30d') {
      return List.generate(dataPoints, (i) {
        final date = now.subtract(Duration(days: (dataPoints - 1 - i) * 2));
        return '${date.month}/${date.day}';
      });
    } else {
      return List.generate(dataPoints, (i) {
        final date = now.subtract(Duration(days: (dataPoints - 1 - i) * 3));
        return '${date.month}/${date.day}';
      });
    }
  }

  double _getMaxX() {
    return (_chartData[_selectedPeriod]!.length - 1).toDouble();
  }

  int _getXAxisInterval() {
    if (_selectedPeriod == '7d') return 1;
    if (_selectedPeriod == '30d') return 2;
    return 5;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Learning Hours',
                        style: tt.titleMedium?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This month',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedPeriod,
                    underline: const SizedBox.shrink(),
                    icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: cs.onSurfaceVariant),
                    style: tt.bodySmall?.copyWith(color: cs.onSurface),
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    items: const [
                      DropdownMenuItem(value: '7d', child: Text('7d')),
                      DropdownMenuItem(value: '30d', child: Text('30d')),
                      DropdownMenuItem(value: '90d', child: Text('90d')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedPeriod = value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: cs.outlineVariant.withValues(alpha: 0.3),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: cs.outlineVariant.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: _getXAxisInterval().toDouble(),
                        getTitlesWidget: (value, meta) {
                          final labels = _getDateLabels();
                          if (value.toInt() >= 0 && value.toInt() < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[value.toInt()],
                                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 9),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}h',
                            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: _getMaxX(),
                  minY: 0,
                  maxY: 10,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _chartData[_selectedPeriod]!,
                      isCurved: true,
                      color: const Color(0xFF4A90E2),
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF4A90E2).withValues(alpha: 0.3),
                            const Color(0xFF4A90E2).withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => cs.surfaceContainerHighest,
                      tooltipRoundedRadius: 8,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            '${spot.y.toInt()}h',
                            tt.labelSmall!.copyWith(
                              color: cs.onSurface,
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
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4A90E2),
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Study',
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
