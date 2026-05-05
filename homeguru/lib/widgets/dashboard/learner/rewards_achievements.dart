import 'package:flutter/material.dart';

class RewardsAchievements extends StatelessWidget {
  const RewardsAchievements({super.key});

  static const List<Map<String, dynamic>> _items = [
    {
      'icon': Icons.emoji_events_rounded,
      'label': 'Rewards',
      'gradientColors': [Color(0xFFFFEB3B), Color(0xFFFF6F00)], // Golden gradient (bright yellow to deep orange)
    },
    {
      'icon': Icons.card_giftcard_rounded,
      'label': 'Referrals',
      'gradientColors': [Color(0xFFFF5252), Color(0xFFB71C1C)], // Red gradient (bright red to dark red)
    },
    {
      'icon': Icons.workspace_premium_rounded,
      'label': 'Certifications',
      'gradientColors': [Color(0xFF2196F3), Color(0xFF0D47A1)], // Blue gradient (bright blue to deep blue)
    },
    {
      'icon': Icons.storefront_rounded,
      'label': 'Store',
      'gradientColors': [Color(0xFFBA68C8), Color(0xFF6A1B9A)], // Violet gradient (light violet to deep violet)
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Icon(Icons.stars_rounded, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Rewards & Achievements',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final spacing = 16.0;
            final itemWidth = (availableWidth - (3 * spacing)) / 4;
            final circleSize = itemWidth.clamp(40.0, 56.0);

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _items.map((item) {
                return GestureDetector(
                  onTap: () {},
                  child: SizedBox(
                    width: itemWidth,
                    child: Column(
                      children: [
                        Container(
                          width: circleSize,
                          height: circleSize,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: item['gradientColors'],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: cs.outlineVariant.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              item['icon'],
                              color: Colors.white.withValues(alpha: 0.75),
                              size: circleSize * 0.45,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['label'],
                          style: tt.labelMedium?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
