import 'package:flutter/material.dart';
import 'stat_card.dart';

class StatsCarousel extends StatelessWidget {
  const StatsCarousel({super.key});

  static const _stats = [
    (value: '1240', label: 'XP', icon: Icons.stars_rounded),
    (value: '7d', label: 'Streak', icon: Icons.local_fire_department_rounded),
    (value: '156', label: 'Sessions', icon: Icons.event_available_rounded),
    (value: '89.5h', label: 'Hours', icon: Icons.schedule_rounded),
    (value: '3', label: 'Tutors', icon: Icons.people_rounded),
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
              Icon(Icons.analytics_rounded, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Your Stats',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 120,
          child: CarouselView.weighted(
            flexWeights: const [3, 2, 1],
            itemSnapping: true,
            padding: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            children: [
              ...List.generate(_stats.length, (i) {
                final stat = _stats[i];

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;

                    final isSmall = w < 72;
                    final isMedium = w < 120;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: StatCard(
                        value: stat.value,
                        label: stat.label,
                        icon: stat.icon,
                        bgColor: cs.surface,
                        fgColor: cs.onSurface,
                        accentColor: cs.primary,
                        showLabel: !isMedium,
                        showValue: !isSmall,
                        iconSize: isSmall ? 22.0 : (isMedium ? 26.0 : 30.0),
                      ),
                    );
                  },
                );
              }),
              LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final isSmall = w < 72;
                  final isMedium = w < 120;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {},
                          child: Stack(
                            children: [
                              if (!isSmall)
                                Positioned(
                                  right: -8,
                                  bottom: -8,
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 80,
                                    color: cs.onSurfaceVariant.withValues(alpha: 0.1),
                                  ),
                                ),
                              Center(
                                child: isSmall
                                    ? Icon(
                                        Icons.grid_view_rounded,
                                        size: 22,
                                        color: cs.onSurfaceVariant,
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.grid_view_rounded,
                                            size: isMedium ? 26 : 40,
                                            color: cs.onSurfaceVariant,
                                          ),
                                          if (!isMedium) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              'View All',
                                              style: TextStyle(
                                                color: cs.onSurface,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Stats',
                                              style: TextStyle(
                                                color: cs.onSurfaceVariant,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
