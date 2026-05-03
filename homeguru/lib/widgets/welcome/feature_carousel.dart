import 'package:flutter/material.dart';

class FeatureCarousel extends StatelessWidget {
  const FeatureCarousel({super.key});

  static const _items = [
    (
      icon: Icons.auto_stories_rounded,
      title: 'Expert-led\nlearning',
      body: 'Live sessions, recorded courses & personalised study plans built around you.',
      label: 'LEARN',
    ),
    (
      icon: Icons.verified_user_rounded,
      title: 'Verified\ntutors',
      body: 'Every tutor is background-checked, rated by the community and ready to help.',
      label: 'TRUST',
    ),
    (
      icon: Icons.emoji_events_rounded,
      title: 'Earn &\ngrow',
      body: 'Badges, streaks and real rewards for every milestone you hit.',
      label: 'GROW',
    ),
    (
      icon: Icons.schedule_rounded,
      title: 'Your\nschedule',
      body: 'Book sessions that fit your life — any day, any time, any device.',
      label: 'FLEX',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final cardColors = [
      (bg: cs.primaryContainer, fg: cs.onPrimaryContainer, accent: cs.primary),
      (bg: cs.secondaryContainer, fg: cs.onSecondaryContainer, accent: cs.secondary),
      (bg: cs.tertiaryContainer, fg: cs.onTertiaryContainer, accent: cs.tertiary),
      (bg: cs.tertiaryContainer, fg: cs.onTertiaryContainer, accent: cs.tertiary),
    ];

    return LayoutBuilder(builder: (ctx, outer) {
      final itemExtent = outer.maxWidth - 88;
      const shrinkExtent = 88.0;

      return CarouselView(
        itemExtent: itemExtent,
        shrinkExtent: shrinkExtent,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemSnapping: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        children: List.generate(_items.length, (i) {
          final item = _items[i];
          final c = cardColors[i];

          return RepaintBoundary(
            child: LayoutBuilder(builder: (_, inner) {
              final isShrunk = inner.maxWidth < itemExtent * 0.5;

              return Container(
                decoration: BoxDecoration(color: c.bg),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    if (!isShrunk)
                      Positioned(
                        right: -12,
                        bottom: -12,
                        child: Icon(item.icon,
                            size: 180,
                            color: c.accent.withValues(alpha: 0.07)),
                      ),

                    if (isShrunk)
                      Center(
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Text(item.label,
                              style: tt.labelSmall?.copyWith(
                                color: c.fg.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              )),
                        ),
                      ),

                    if (!isShrunk)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: c.accent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(item.label,
                                      style: tt.labelSmall?.copyWith(
                                        color: c.accent,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                      )),
                                ),
                                const Spacer(),
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: c.fg.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(item.icon, size: 24, color: c.fg),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(item.title,
                                style: tt.headlineLarge?.copyWith(
                                  color: c.fg,
                                  height: 1.05,
                                  fontWeight: FontWeight.w800,
                                )),
                            const SizedBox(height: 10),
                            Text(item.body,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: tt.bodyMedium?.copyWith(
                                  color: c.fg.withValues(alpha: 0.72),
                                  height: 1.55,
                                )),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }),
          );
        }),
      );
    });
  }
}
