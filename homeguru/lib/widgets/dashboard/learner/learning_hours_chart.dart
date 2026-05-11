import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../services/learner_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LearningHoursChart extends StatefulWidget {
  const LearningHoursChart({super.key});

  @override
  State<LearningHoursChart> createState() => _LearningHoursChartState();
}

class _LearningHoursChartState extends State<LearningHoursChart> {
  String _selectedPeriod = '7d';
  Map<String, List<FlSpot>> _chartData = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final learnerId = prefs.getString('userId');
      if (learnerId != null) {
        final stats = await LearnerDataModel.fetchLearnerStats(learnerId);
        final hoursData = stats['hoursData'] as Map<String, dynamic>?;
        if (mounted) {
          setState(() {
            if (hoursData != null) {
              _chartData = {
                '7d': _parseChartData(hoursData['7d'] as List?),
                '30d': _parseChartData(hoursData['30d'] as List?),
                '90d': _parseChartData(hoursData['90d'] as List?),
              };
            } else {
              _chartData = _getDefaultData();
            }
            _loading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _chartData = _getDefaultData();
            _loading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading chart data: $e');
      if (mounted) {
        setState(() {
          _chartData = _getDefaultData();
          _loading = false;
        });
      }
    }
  }

  List<FlSpot> _parseChartData(List? data) {
    if (data == null || data.isEmpty) return [];
    return List.generate(data.length, (i) {
      final value = data[i] is num ? (data[i] as num).toDouble() : 0.0;
      return FlSpot(i.toDouble(), value);
    });
  }

  Map<String, List<FlSpot>> _getDefaultData() {
    return {
      '7d': List.generate(7, (i) => FlSpot(i.toDouble(), 0)),
      '30d': List.generate(15, (i) => FlSpot(i.toDouble(), 0)),
      '90d': List.generate(30, (i) => FlSpot(i.toDouble(), 0)),
    };
  }

  List<String> _getDateLabels() {
    if (_chartData.isEmpty || _chartData[_selectedPeriod] == null) return [];
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
    if (_chartData.isEmpty || _chartData[_selectedPeriod] == null) return 0;
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

    if (_loading || _chartData.isEmpty) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

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
