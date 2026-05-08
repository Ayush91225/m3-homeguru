import 'package:flutter/material.dart';
import '../../../widgets/shared/guruai/ai_match_card.dart';
import '../../../widgets/shared/guruai/matching_bottom_sheet.dart';
import '../../../widgets/dashboard/learner/stats_carousel.dart';
import '../../../widgets/dashboard/learner/upcoming_card.dart';
import '../../../widgets/dashboard/learner/review_lessons.dart';
import '../../../widgets/dashboard/learner/my_tutors.dart';
import '../../../widgets/dashboard/learner/suggested_tutors.dart';
import '../../../widgets/dashboard/learner/rewards_achievements.dart';
import '../../../widgets/dashboard/learner/learning_hours_chart.dart';
import '../../../widgets/dashboard/learner/streak_calendar.dart';
import 'learner_dashboard.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  void _showMatchingBottomSheet(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MatchingBottomSheet(),
    );
    if (result != null && context.mounted) {
      Navigator.pushNamed(context, '/search-results', arguments: result as String);
    }
  }

  static const _itemCount = 14;

  Widget _item(BuildContext context, int i) {
    switch (i) {
      case 0: return AIMatchCard(onTap: () => _showMatchingBottomSheet(context));
      case 1: return const SizedBox(height: 20);
      case 2: return const StatsCarousel();
      case 3: return const SizedBox(height: 20);
      case 4: return UpcomingCard(
        onScheduleTap: () {
          final s = context.findAncestorStateOfType<LearnerDashboardState>();
          s?.onItemTapped(2);
        },
      );
      case 5: return const SizedBox(height: 20);
      case 6: return const ReviewLessons();
      case 7: return const SizedBox(height: 20);
      case 8: return const MyTutors();
      case 9: return const SizedBox(height: 20);
      case 10: return const SuggestedTutors();
      case 11: return const SizedBox(height: 20);
      case 12: return const RewardsAchievements();
      case 13: return const SizedBox(height: 20);
      case 14: return _StreakHeader();
      case 15: return const LearningHoursChart();
      case 16: return const SizedBox(height: 20);
      case 17: return const StreakCalendar();
      default: return const SizedBox(height: 32);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _item(context, i),
              childCount: _itemCount + 5,
            ),
          ),
        ),
      ],
    );
  }
}

class _StreakHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Row(
        children: [
          Icon(Icons.trending_up_rounded, size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Text('Streak & Progress', style: tt.bodyMedium?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}
