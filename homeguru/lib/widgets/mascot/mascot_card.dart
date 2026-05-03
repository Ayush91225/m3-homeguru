import 'package:flutter/material.dart';
import 'hoot_sprite.dart';

class MascotCard extends StatelessWidget {
  const MascotCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final size = MediaQuery.sizeOf(context);
    final spriteSize = size.width >= 600 ? 130.0 : size.height < 700 ? 90.0 : 110.0;

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primaryContainer, cs.surfaceContainerLow],
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.12),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome_rounded,
                                  size: 12, color: cs.primary),
                              const SizedBox(width: 4),
                              Text('Meet Hoot',
                                  style: tt.labelSmall?.copyWith(
                                      color: cs.primary,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Hi! Ready to learn\nsomething amazing?',
                        style: tt.titleMedium?.copyWith(
                          color: cs.onSurface,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Live pill
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          border: Border.all(
                              color: cs.outlineVariant, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: cs.tertiary,
                                  shape: BoxShape.circle,
                                ),
                                child: const SizedBox(width: 7, height: 7),
                              ),
                              const SizedBox(width: 6),
                              Text('12,400 live sessions',
                                  style: tt.labelSmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              HootSprite(size: spriteSize),
            ],
          ),
        ),
      ),
    );
  }
}
