import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../widgets/mascot/chill_sprite.dart';

class LearnerStep6Body extends StatelessWidget {
  const LearnerStep6Body({super.key, required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= 600 ? w * 0.2 : 24.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ChillSprite(size: 140),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Stack(
                    children: [
                      // Watermark emoji
                      Positioned(
                        right: -8,
                        bottom: -8,
                        child: Text(
                          '🎯',
                          style: TextStyle(
                            fontSize: 80,
                            color: cs.onPrimaryContainer.withValues(alpha: 0.06),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          const Text('🎯', style: TextStyle(fontSize: 36)),
                          const SizedBox(height: 16),
                          Text(
                            'Fun fact',
                            style: tt.titleLarge?.copyWith(
                              color: cs.onPrimaryContainer,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Learners who study 1-on-1 outperform 98% of classroom students.',
                            textAlign: TextAlign.center,
                            style: tt.bodyLarge?.copyWith(
                              color: cs.onPrimaryContainer,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '— Benjamin Bloom, 1984',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onPrimaryContainer.withValues(alpha: 0.6),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "You're about to join thousands of learners already on HomeGuru. Let's set up your profile!",
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
          child: FilledButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              onNext();
            },
            child: const Text("Let's go!"),
          ),
        ),
      ],
    );
  }
}
