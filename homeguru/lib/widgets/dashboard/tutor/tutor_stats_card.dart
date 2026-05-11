import 'package:flutter/material.dart';
import '../../../services/tutor_data_model.dart';

class TutorStatsCarousel extends StatelessWidget {
  const TutorStatsCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final data = TutorData.of(context);
    final raw = data.raw;

    // Pull stats from model, fallback to 0
    final stats = raw['stats'] as Map<String, dynamic>? ?? {};
    final earnings = stats['monthlyEarnings'] ?? 0;
    final activeStudents = stats['activeStudents'] ?? 0;
    final avgRating = stats['avgRating'] ?? 0.0;
    final reviewCount = stats['reviewCount'] ?? 0;
    final classesThisWeek = stats['classesThisWeek'] ?? 0;
    final hoursThisWeek = stats['hoursThisWeek'] ?? 0.0;
    final sessionsThisWeek = stats['sessionsThisWeek'] ?? 0;
    final followers = stats['followers'] ?? 0;
    final impressions = stats['impressions'] ?? 0;
    final profileViews = stats['profileViews'] ?? 0;

    final statsList = <Map<String, dynamic>>[
      {
        'icon': Icons.currency_rupee_rounded,
        'title': 'Monthly Earnings',
        'value': '₹$earnings',
        'changeValue': '',
        'changeText': 'this month',
      },
      {
        'icon': Icons.people_rounded,
        'title': 'Active Students',
        'value': '$activeStudents',
        'changeValue': '',
        'changeText': '',
      },
      {
        'icon': Icons.star_outline_rounded,
        'title': 'Avg Rating',
        'value': '$avgRating',
        'changeValue': '$reviewCount',
        'changeText': 'reviews',
      },
      {
        'icon': Icons.school_rounded,
        'title': 'Classes Taken',
        'value': '$classesThisWeek',
        'changeValue': 'This Week',
        'changeText': '',
      },
      {
        'icon': Icons.schedule_rounded,
        'title': 'Teaching Hours',
        'value': '$hoursThisWeek',
        'changeValue': 'This Week',
        'changeText': '',
      },
      {
        'icon': Icons.event_available_rounded,
        'title': 'Sessions',
        'value': '$sessionsThisWeek',
        'changeValue': 'This Week',
        'changeText': '',
      },
      {
        'icon': Icons.person_add_rounded,
        'title': 'Followers',
        'value': '$followers',
        'changeValue': '',
        'changeText': 'total',
      },
      {
        'icon': Icons.visibility_rounded,
        'title': 'Profile Impressions',
        'value': '$impressions',
        'changeValue': '',
        'changeText': 'this month',
      },
      {
        'icon': Icons.remove_red_eye_rounded,
        'title': 'Profile Views',
        'value': '$profileViews',
        'changeValue': '',
        'changeText': 'this week',
      },
    ];

    return SizedBox(
      height: 140,
      child: CarouselView.weighted(
        flexWeights: const [3, 2, 1],
        itemSnapping: true,
        padding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        children: statsList.map((stat) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final isSmall = w < 100;
              final isMedium = w < 200;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _StatCard(stat: stat, isSmall: isSmall, isMedium: isMedium),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final Map<String, dynamic> stat;
  final bool isSmall;
  final bool isMedium;

  const _StatCard({required this.stat, required this.isSmall, required this.isMedium});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (isSmall) {
      return Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Center(child: Icon(stat['icon'], size: 32, color: cs.tertiary)),
      );
    }

    if (isMedium) {
      return Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: cs.surfaceContainerHigh, shape: BoxShape.circle),
            child: Icon(stat['icon'], size: 18, color: cs.tertiary),
          ),
          const SizedBox(height: 8),
          Text(stat['title'], style: tt.labelMedium?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
          const Spacer(),
          Text(stat['value'], style: tt.titleLarge?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w400)),
        ]),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: cs.surfaceContainerHigh, shape: BoxShape.circle),
            child: Icon(stat['icon'], size: 20, color: cs.tertiary),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(stat['title'], style: tt.labelLarge?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
        const Spacer(),
        Text(stat['value'], style: tt.headlineSmall?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w400)),
        const SizedBox(height: 8),
        Row(children: [
          if ((stat['changeValue'] as String).isNotEmpty)
            Text(stat['changeValue'], style: tt.labelSmall?.copyWith(color: cs.tertiary, fontWeight: FontWeight.w600)),
          if ((stat['changeValue'] as String).isNotEmpty && (stat['changeText'] as String).isNotEmpty)
            const SizedBox(width: 4),
          if ((stat['changeText'] as String).isNotEmpty)
            Expanded(child: Text(stat['changeText'], style: tt.labelSmall?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
      ]),
    );
  }
}
