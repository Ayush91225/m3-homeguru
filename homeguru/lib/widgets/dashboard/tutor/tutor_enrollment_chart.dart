import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../services/tutor_data_model.dart';

class TutorEnrollmentChart extends StatelessWidget {
  const TutorEnrollmentChart({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final data = TutorData.of(context);

    // Pull enrollment data from stats, or build from rates/subjects
    final stats = data.raw['stats'] as Map<String, dynamic>? ?? {};
    final enrollmentBySubject = stats['enrollmentBySubject'] as Map<String, dynamic>? ?? {};

    // If no enrollment data, use subject names from rates with 0
    List<String> labels;
    List<double> values;

    if (enrollmentBySubject.isNotEmpty) {
      labels = List<String>.from(enrollmentBySubject.keys);
      values = List<double>.from(enrollmentBySubject.values.map((v) => (v as num).toDouble()));
    } else {
      final rates = data.rates;
      if (rates.isNotEmpty) {
        labels = List<String>.from(rates.map((r) => r['subject']?.toString() ?? '').toSet());
        values = List<double>.filled(labels.length, 0.0, growable: true);
      } else {
        labels = ['No subjects'];
        values = [0];
      }
    }

    // Limit to 6 for radar chart readability
    if (labels.length > 6) {
      labels = labels.sublist(0, 6);
      values = values.sublist(0, 6);
    }

    // Ensure at least 3 points for radar
    while (labels.length < 3) {
      labels.add('—');
      values.add(0);
    }


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(children: [
            Icon(Icons.emoji_events_rounded, size: 18, color: cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Text('Most Enrolled Students', style: tt.bodyMedium?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w400)),
          ]),
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
              ticksTextStyle: tt.labelSmall?.copyWith(color: Colors.transparent, fontSize: 0),
              radarBackgroundColor: Colors.transparent,
              dataSets: [
                RadarDataSet(
                  fillColor: cs.tertiary.withValues(alpha: 0.5),
                  borderColor: cs.tertiary,
                  borderWidth: 2,
                  dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
                ),
              ],
              getTitle: (index, angle) {
                return RadarChartTitle(
                  text: labels[index],
                  angle: angle,
                  positionPercentageOffset: 0.15,
                );
              },
              titleTextStyle: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 11),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            enrollmentBySubject.isNotEmpty ? 'Enrollment by subject · this month' : 'No enrollment data yet',
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 11),
          ),
        ),
      ],
    );
  }
}
