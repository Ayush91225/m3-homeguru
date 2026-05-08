import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TutorEnrollmentChart extends StatelessWidget {
  const TutorEnrollmentChart({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Icon(Icons.emoji_events_rounded, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Most Enrolled Students',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: RadarChart(
            RadarChartData(
              radarShape: RadarShape.polygon,
              radarBorderData: BorderSide(color: cs.outlineVariant, width: 1),
              gridBorderData: BorderSide(color: cs.outlineVariant, width: 1),
              tickBorderData: BorderSide(color: cs.outlineVariant, width: 1),
              tickCount: 4,
              ticksTextStyle: tt.labelSmall?.copyWith(
                color: Colors.transparent,
                fontSize: 0,
              ),
              radarBackgroundColor: Colors.transparent,
              radarTouchData: RadarTouchData(
                enabled: true,
                touchCallback: (FlTouchEvent event, response) {},
              ),
              dataSets: [
                RadarDataSet(
                  fillColor: cs.tertiary.withValues(alpha: 0.5),
                  borderColor: cs.tertiary,
                  borderWidth: 2,
                  dataEntries: [
                    const RadarEntry(value: 95),
                    const RadarEntry(value: 65),
                    const RadarEntry(value: 75),
                    const RadarEntry(value: 40),
                    const RadarEntry(value: 45),
                    const RadarEntry(value: 80),
                  ],
                ),
              ],
              getTitle: (index, angle) {
                final titles = ['JEE Maths', 'Physics', 'Chemistry', 'Biology', 'English', 'Hindi'];
                return RadarChartTitle(
                  text: titles[index],
                  angle: angle,
                  positionPercentageOffset: 0.15,
                );
              },
              titleTextStyle: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Enrollment by subject · this month',
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
