import 'package:flutter/material.dart';
import '../../../screens/dashboard/learner/rewards_screen.dart';

const _badges = [
  (icon: Icons.local_fire_department_rounded, title: '7-Day', unlocked: true),
  (icon: Icons.star_rounded, title: 'First', unlocked: true),
  (icon: Icons.military_tech_rounded, title: 'Top 10%', unlocked: true),
  (icon: Icons.bolt_rounded, title: 'Quick', unlocked: true),
  (icon: Icons.workspace_premium_rounded, title: 'Verified', unlocked: false),
  (icon: Icons.favorite_rounded, title: "Tutor's", unlocked: false),
  (icon: Icons.emoji_events_rounded, title: 'XP 1K+', unlocked: false),
  (icon: Icons.school_rounded, title: '10 Sess', unlocked: false),
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
    final tt = Theme.of(context).textTheme;
    final unlocked = _badges.where((b) => b.unlocked).length;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFDD835), Color(0xFFF57C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                  color: Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RewardsScreen()));
                },
                icon: const Icon(Icons.open_in_new_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // title + count
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text('Rewards',
                  style: tt.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Text('$unlocked / ${_badges.length}',
                    style: tt.labelMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // badges
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _badges.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final b = _badges[i];
                return Container(
                  width: 64,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: b.unlocked
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: b.unlocked
                            ? Colors.white.withValues(alpha: 0.4)
                            : Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(b.icon,
                          size: 24,
                          color: b.unlocked
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.4)),
                      const SizedBox(height: 4),
                      Text(b.title,
                          style: tt.labelSmall?.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: b.unlocked
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5)),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
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
