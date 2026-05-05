import 'package:flutter/material.dart';

class ReferralsSheet extends StatelessWidget {
  const ReferralsSheet({super.key});

  static void show(BuildContext context) => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => const ReferralsSheet(),
      );

  static const _friends = [
    (name: 'Aryan Mehta', xp: '200 XP'),
    (name: 'Priya Sharma', xp: '200 XP'),
    (name: 'Rohan Gupta', xp: 'Pending'),
  ];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEF5350), Color(0xFFC62828)],
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
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.open_in_new_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // title
          Row(
            children: [
              const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text('Referrals',
                  style: tt.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          // friends
          ..._friends.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(f.name[0],
                          style: tt.labelMedium?.copyWith(
                              color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(f.name,
                          style: tt.bodyMedium?.copyWith(
                              color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                    Text(f.xp,
                        style: tt.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          // view all button
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
              side: const BorderSide(color: Colors.white, width: 1.5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }
}
