import 'package:flutter/material.dart';

const _allBadges = [
  (icon: Icons.local_fire_department_rounded, title: '7-Day Streak', desc: 'Studied 7 days in a row', unlocked: true),
  (icon: Icons.star_rounded, title: 'First Session', desc: 'Completed your first session', unlocked: true),
  (icon: Icons.military_tech_rounded, title: 'Top Learner', desc: 'Ranked in top 10% this month', unlocked: true),
  (icon: Icons.bolt_rounded, title: 'Quick Starter', desc: 'Booked within 24h of joining', unlocked: true),
  (icon: Icons.workspace_premium_rounded, title: 'Verified Learner', desc: 'Profile fully verified', unlocked: true),
  (icon: Icons.favorite_rounded, title: "Tutor's Pick", desc: 'Recommended by a tutor', unlocked: true),
  (icon: Icons.emoji_events_rounded, title: 'XP Champion', desc: 'Earned 1000+ XP', unlocked: true),
  (icon: Icons.school_rounded, title: '10 Sessions', desc: 'Completed 10 sessions', unlocked: true),
  (icon: Icons.auto_awesome_rounded, title: 'AI Master', desc: 'Used Guru AI 50 times', unlocked: true),
  (icon: Icons.calendar_month_rounded, title: 'Monthly Streak', desc: 'Studied 30 days in a row', unlocked: false),
  (icon: Icons.groups_rounded, title: 'Social Learner', desc: 'Referred 5 friends', unlocked: false),
  (icon: Icons.trending_up_rounded, title: 'Progress Pro', desc: 'Improved grade by 2 levels', unlocked: false),
  (icon: Icons.timer_rounded, title: 'Speed Demon', desc: 'Completed 10 sessions in a week', unlocked: false),
  (icon: Icons.library_books_rounded, title: 'Bookworm', desc: 'Studied 5 different subjects', unlocked: false),
  (icon: Icons.psychology_rounded, title: 'Deep Thinker', desc: 'Asked 100 questions', unlocked: false),
  (icon: Icons.celebration_rounded, title: 'Century Club', desc: 'Completed 100 sessions', unlocked: false),
  (icon: Icons.diamond_rounded, title: 'Diamond Learner', desc: 'Earned 10,000 XP', unlocked: false),
  (icon: Icons.workspace_premium_rounded, title: 'Premium Member', desc: 'Active for 1 year', unlocked: false),
  (icon: Icons.stars_rounded, title: 'All Star', desc: 'Unlocked all badges', unlocked: false),
];

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final unlocked = _allBadges.where((b) => b.unlocked).toList();
    final unlockedCount = unlocked.length;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ── app bar ──
          SliverAppBar(
            floating: true,
            backgroundColor: cs.surface,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Rewards', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ),

          // ── hero section ──
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.primaryContainer.withValues(alpha: 0.6),
                    cs.primaryContainer.withValues(alpha: 0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
              ),
              child: Stack(
                children: [
                  // subtle doodles
                  Positioned(top: 15, right: 25, child: _Doodle(color: cs.primary.withValues(alpha: 0.15), size: 8)),
                  Positioned(top: 45, right: 65, child: _Doodle(color: cs.primary.withValues(alpha: 0.12), size: 6)),
                  Positioned(bottom: 35, left: 35, child: _Doodle(color: cs.primary.withValues(alpha: 0.15), size: 10)),
                  Positioned(bottom: 65, left: 75, child: _Doodle(color: cs.primary.withValues(alpha: 0.12), size: 7)),
                  
                  Column(
                    children: [
                      Icon(Icons.emoji_events_rounded, size: 44, color: cs.primary),
                      const SizedBox(height: 12),
                      Text('$unlockedCount / ${_allBadges.length}',
                          style: tt.displaySmall?.copyWith(
                              fontWeight: FontWeight.w900, color: cs.onSurface, height: 1)),
                      const SizedBox(height: 4),
                      Text('Badges Unlocked',
                          style: tt.bodyLarge?.copyWith(
                              color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome_rounded, size: 16, color: cs.primary),
                            const SizedBox(width: 6),
                            Text('Keep going!',
                                style: tt.labelLarge?.copyWith(
                                    color: cs.primary, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── horizontal scroll - all badges ──
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.grid_view_rounded, size: 18, color: cs.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text('All Badges',
                          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _allBadges.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final b = _allBadges[i];
                      return _BadgeChip(b: b, cs: cs, tt: tt);
                    },
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),

          // ── unlocked badges grid ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.stars_rounded, size: 18, color: cs.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text('Your Collection',
                          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: unlocked.length,
                    itemBuilder: (_, i) => _UnlockedBadgeTile(b: unlocked[i], cs: cs, tt: tt),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Doodle extends StatelessWidget {
  const _Doodle({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.5,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.b, required this.cs, required this.tt});
  final ({IconData icon, String title, String desc, bool unlocked}) b;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: b.unlocked
            ? cs.primaryContainer.withValues(alpha: 0.5)
            : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: b.unlocked
                ? cs.primary.withValues(alpha: 0.25)
                : cs.outlineVariant.withValues(alpha: 0.3),
            width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: b.unlocked
                  ? cs.primary.withValues(alpha: 0.15)
                  : cs.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(b.icon,
                size: 24,
                color: b.unlocked
                    ? cs.primary
                    : cs.onSurfaceVariant.withValues(alpha: 0.3)),
          ),
          const SizedBox(height: 8),
          Text(b.title,
              style: tt.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: b.unlocked
                      ? cs.onSurface
                      : cs.onSurfaceVariant.withValues(alpha: 0.4)),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _UnlockedBadgeTile extends StatelessWidget {
  const _UnlockedBadgeTile({required this.b, required this.cs, required this.tt});
  final ({IconData icon, String title, String desc, bool unlocked}) b;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primaryContainer.withValues(alpha: 0.5),
            cs.primaryContainer.withValues(alpha: 0.25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(b.icon, size: 32, color: cs.primary),
          ),
          const SizedBox(height: 12),
          Text(b.title,
              style: tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800, color: cs.onSurface),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(b.desc,
              style: tt.bodySmall?.copyWith(
                  fontSize: 11, color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
