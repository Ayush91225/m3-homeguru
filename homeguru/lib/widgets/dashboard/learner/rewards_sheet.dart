import 'package:flutter/material.dart';
import '../../../screens/dashboard/learner/rewards_screen.dart';

const _badges = [
  (icon: Icons.local_fire_department_rounded, title: '7-Day', unlocked: true, colorIndex: 0),
  (icon: Icons.star_rounded, title: 'First', unlocked: true, colorIndex: 1),
  (icon: Icons.military_tech_rounded, title: 'Top 10%', unlocked: true, colorIndex: 2),
  (icon: Icons.bolt_rounded, title: 'Quick', unlocked: true, colorIndex: 3),
  (icon: Icons.workspace_premium_rounded, title: 'Verified', unlocked: true, colorIndex: 4),
  (icon: Icons.favorite_rounded, title: "Tutor's", unlocked: true, colorIndex: 5),
  (icon: Icons.emoji_events_rounded, title: 'XP 1K+', unlocked: true, colorIndex: 6),
  (icon: Icons.school_rounded, title: '10 Sess', unlocked: true, colorIndex: 7),
  (icon: Icons.auto_awesome_rounded, title: 'AI', unlocked: true, colorIndex: 8),
  (icon: Icons.calendar_month_rounded, title: 'Monthly', unlocked: false, colorIndex: 0),
  (icon: Icons.groups_rounded, title: 'Social', unlocked: false, colorIndex: 1),
  (icon: Icons.trending_up_rounded, title: 'Progress', unlocked: false, colorIndex: 2),
  (icon: Icons.timer_rounded, title: 'Speed', unlocked: false, colorIndex: 3),
  (icon: Icons.library_books_rounded, title: 'Books', unlocked: false, colorIndex: 4),
  (icon: Icons.psychology_rounded, title: 'Thinker', unlocked: false, colorIndex: 5),
  (icon: Icons.celebration_rounded, title: 'Century', unlocked: false, colorIndex: 6),
  (icon: Icons.diamond_rounded, title: 'Diamond', unlocked: false, colorIndex: 7),
  (icon: Icons.workspace_premium_rounded, title: 'Premium', unlocked: false, colorIndex: 8),
  (icon: Icons.stars_rounded, title: 'All Star', unlocked: false, colorIndex: 6),
];

// Referrals-style colors
const _badgeColors = [
  (light: Color(0xFF81C784), dark: Color(0xFF81C784)), // Green
  (light: Color(0xFF64B5F6), dark: Color(0xFF64B5F6)), // Blue
  (light: Color(0xFF9575CD), dark: Color(0xFF9575CD)), // Purple
  (light: Color(0xFFFFB74D), dark: Color(0xFFFFB74D)), // Orange
  (light: Color(0xFFF06292), dark: Color(0xFFF06292)), // Pink
  (light: Color(0xFF4DB6AC), dark: Color(0xFF4DB6AC)), // Teal
  (light: Color(0xFFE57373), dark: Color(0xFFEF5350)), // Red
  (light: Color(0xFFFFD54F), dark: Color(0xFFFFD54F)), // Amber
  (light: Color(0xFF90CAF9), dark: Color(0xFF90CAF9)), // Light Blue
];

class RewardsSheet extends StatelessWidget {
  const RewardsSheet({super.key});

  static void show(BuildContext context) => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => const RewardsSheet(),
      );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final unlocked = _badges.where((b) => b.unlocked).length;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // handle + open
          Row(
            children: [
              const Spacer(),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RewardsScreen()));
                },
                icon: Icon(Icons.open_in_new_rounded, color: cs.primary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // title + count
          Row(
            children: [
              Text('Rewards',
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$unlocked unlocked',
                    style: tt.labelMedium?.copyWith(
                        color: cs.onPrimaryContainer, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // badges
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _badges.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final b = _badges[i];
                final badgeColor = isDark 
                    ? _badgeColors[b.colorIndex % _badgeColors.length].dark
                    : _badgeColors[b.colorIndex % _badgeColors.length].light;
                
                return Container(
                  width: 70,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: isDark ? 0.25 : 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(b.icon,
                            size: 20,
                            color: badgeColor),
                      ),
                      const SizedBox(height: 6),
                      Text(b.title,
                          style: tt.labelSmall?.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      if (!b.unlocked) ...[
                        const SizedBox(height: 2),
                        Icon(Icons.lock_rounded, size: 10, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
