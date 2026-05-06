import 'package:flutter/material.dart';
import '../../../screens/dashboard/learner/referrals_screen.dart';

class ReferralsSheet extends StatelessWidget {
  const ReferralsSheet({super.key});

  static void show(BuildContext context) => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => const ReferralsSheet(),
      );

  static const _friends = [
    (name: 'Aryan Mehta', xp: '200 XP', status: 'joined'),
    (name: 'Priya Sharma', xp: '200 XP', status: 'joined'),
    (name: 'Rohan Gupta', xp: 'Pending', status: 'pending'),
    (name: 'Sneha Patel', xp: '200 XP', status: 'joined'),
    (name: 'Vikram Singh', xp: 'Pending', status: 'pending'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final earnedXP = _friends.where((f) => f.status == 'joined').length * 200;

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
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferralsScreen()));
                },
                icon: Icon(Icons.open_in_new_rounded, color: cs.primary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // title + earned XP
          Row(
            children: [
              Text('Referrals',
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$earnedXP XP earned',
                    style: tt.labelMedium?.copyWith(
                        color: cs.onPrimaryContainer, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // friends list
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _friends.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final f = _friends[i];
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final isJoined = f.status == 'joined';
                
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
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: cs.primaryContainer,
                        child: Text(f.name[0],
                            style: tt.labelLarge?.copyWith(
                                color: cs.onPrimaryContainer, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 6),
                      Text(f.name.split(' ')[0],
                          style: tt.labelSmall?.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      if (!isJoined) ...[
                        const SizedBox(height: 2),
                        Icon(Icons.schedule_rounded, size: 10, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
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
