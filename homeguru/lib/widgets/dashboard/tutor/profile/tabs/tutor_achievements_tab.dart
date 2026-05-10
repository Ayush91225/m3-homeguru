import 'package:flutter/material.dart';

class TutorAchievementsTab extends StatelessWidget {
  const TutorAchievementsTab({super.key, this.viewMode = false});
  
  final bool viewMode;

  static const _badges = [
    (Icons.local_fire_department_rounded, '30-Day Streak',     'Taught 30 days in a row'),
    (Icons.star_rounded,                  'First Session',     'Completed your first session'),
    (Icons.military_tech_rounded,         'Top Tutor',         'Ranked in top 5% this month'),
    (Icons.bolt_rounded,                  'Quick Responder',   'Average response time < 2h'),
    (Icons.workspace_premium_rounded,     'Verified Tutor',    'Profile fully verified'),
    (Icons.favorite_rounded,              'Student Favorite',  '50+ positive reviews'),
    (Icons.emoji_events_rounded,          '100 Sessions',      'Completed 100+ sessions'),
    (Icons.trending_up_rounded,           'Rising Star',       'Fastest growing tutor'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: _badges.length,
      itemBuilder: (_, i) => _BadgeTile(
        icon: _badges[i].$1,
        title: _badges[i].$2,
        subtitle: _badges[i].$3,
        cs: cs,
        tt: tt,
        unlocked: i < 5,
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({
    required this.icon, required this.title, required this.subtitle,
    required this.cs, required this.tt, required this.unlocked,
  });
  final IconData icon;
  final String title, subtitle;
  final ColorScheme cs;
  final TextTheme tt;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked ? cs.tertiaryContainer.withValues(alpha: 0.5) : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: unlocked ? Border.all(color: cs.tertiary.withValues(alpha: 0.25)) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32,
              color: unlocked ? cs.tertiary : cs.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 8),
          Text(title,
              style: tt.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: unlocked ? cs.onSurface : cs.onSurfaceVariant.withValues(alpha: 0.5)),
              textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(subtitle,
              style: tt.labelSmall?.copyWith(
                  fontSize: 10,
                  color: unlocked ? cs.onSurfaceVariant : cs.onSurfaceVariant.withValues(alpha: 0.4)),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
