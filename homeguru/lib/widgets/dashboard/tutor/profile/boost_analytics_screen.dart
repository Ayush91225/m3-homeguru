import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BoostAnalyticsScreen extends StatelessWidget {
  const BoostAnalyticsScreen({
    super.key,
    required this.city,
    required this.budget,
    required this.duration,
  });

  final String city;
  final int budget;
  final int duration;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final daysLeft = duration - 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boost Analytics'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.tertiaryContainer, cs.tertiaryContainer.withValues(alpha: 0.3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.tertiary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.tertiary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.rocket_launch, color: cs.onTertiary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Active Campaign', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          Text(city, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 8, color: Colors.green.shade700),
                          const SizedBox(width: 6),
                          Text(
                            'Live',
                            style: tt.labelSmall?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        label: 'Daily Budget',
                        value: '₹$budget',
                        cs: cs,
                        tt: tt,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        label: 'Days Left',
                        value: '$daysLeft',
                        cs: cs,
                        tt: tt,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        label: 'Total Spent',
                        value: '₹${budget * 3}',
                        cs: cs,
                        tt: tt,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Performance Overview', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),

          _MetricCard(
            icon: Icons.visibility_outlined,
            label: 'Profile Views',
            value: '1,234',
            change: '+45%',
            changePositive: true,
            cs: cs,
            tt: tt,
          ),
          const SizedBox(height: 12),
          _MetricCard(
            icon: Icons.message_outlined,
            label: 'Inquiries',
            value: '89',
            change: '+67%',
            changePositive: true,
            cs: cs,
            tt: tt,
          ),
          const SizedBox(height: 12),
          _MetricCard(
            icon: Icons.event_available_outlined,
            label: 'Bookings',
            value: '23',
            change: '+120%',
            changePositive: true,
            cs: cs,
            tt: tt,
          ),
          const SizedBox(height: 12),
          _MetricCard(
            icon: Icons.star_outline,
            label: 'Profile Rating',
            value: '4.8',
            change: '+0.2',
            changePositive: true,
            cs: cs,
            tt: tt,
          ),
          const SizedBox(height: 24),

          Text('Views Trend', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 50,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: cs.outlineVariant.withValues(alpha: 0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              days[value.toInt()],
                              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
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
                    spots: const [
                      FlSpot(0, 120),
                      FlSpot(1, 145),
                      FlSpot(2, 180),
                      FlSpot(3, 165),
                      FlSpot(4, 195),
                      FlSpot(5, 210),
                      FlSpot(6, 230),
                    ],
                    isCurved: true,
                    color: cs.tertiary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: cs.tertiary,
                          strokeWidth: 2,
                          strokeColor: cs.surface,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          cs.tertiary.withValues(alpha: 0.3),
                          cs.tertiary.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text('Top Performing Hours', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _HourBar('9 AM - 12 PM', 0.85, cs, tt),
                const SizedBox(height: 12),
                _HourBar('6 PM - 9 PM', 0.72, cs, tt),
                const SizedBox(height: 12),
                _HourBar('12 PM - 3 PM', 0.58, cs, tt),
                const SizedBox(height: 12),
                _HourBar('3 PM - 6 PM', 0.45, cs, tt),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.value,
    required this.cs,
    required this.tt,
  });

  final String label, value;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 10)),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.change,
    required this.changePositive,
    required this.cs,
    required this.tt,
  });

  final IconData icon;
  final String label, value, change;
  final bool changePositive;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: cs.tertiary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(value, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: changePositive
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  changePositive ? Icons.trending_up : Icons.trending_down,
                  size: 14,
                  color: changePositive ? Colors.green.shade700 : Colors.red.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  change,
                  style: tt.labelSmall?.copyWith(
                    color: changePositive ? Colors.green.shade700 : Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HourBar extends StatelessWidget {
  const _HourBar(this.label, this.value, this.cs, this.tt);

  final String label;
  final double value;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            Text('${(value * 100).toInt()}%', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: cs.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(cs.tertiary),
          ),
        ),
      ],
    );
  }
}
