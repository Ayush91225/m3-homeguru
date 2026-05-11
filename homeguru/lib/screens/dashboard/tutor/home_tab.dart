import 'package:flutter/material.dart';
import 'package:homeguru/widgets/dashboard/tutor/tutor_stats_card.dart';
import 'package:homeguru/widgets/dashboard/tutor/tutor_today_schedule.dart';
import 'package:homeguru/widgets/dashboard/tutor/tutor_pending_requests.dart';
import 'package:homeguru/widgets/dashboard/tutor/my_learners.dart';
import 'package:homeguru/widgets/dashboard/tutor/tutor_enrollment_chart.dart';
import 'package:homeguru/widgets/dashboard/tutor/tutor_reports.dart';
import '../../../services/tutor_data_model.dart';
import 'tutor_dashboard.dart';

class TutorHomeTab extends StatelessWidget {
  const TutorHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Welcome back, ${TutorData.of(context).shortName}!',
          style: tt.headlineMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your teaching dashboard',
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        const TutorStatsCarousel(),
        const SizedBox(height: 24),
        TutorTodaySchedule(
          onScheduleTap: () {
            final s = context.findAncestorStateOfType<TutorDashboardState>();
            s?.onItemTapped(2);
          },
        ),
        const SizedBox(height: 24),
        const TutorPendingRequests(),
        const SizedBox(height: 24),
        const MyLearners(),
        const SizedBox(height: 24),
        const TutorEnrollmentChart(),
        const SizedBox(height: 24),
        const TutorReports(),
      ],
    );
  }
}
