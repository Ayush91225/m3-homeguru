import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TutorStep6Body extends StatelessWidget {
  const TutorStep6Body({super.key, required this.passed, required this.score, required this.onContinue});
  final bool passed;
  final int score;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= 600 ? w * 0.2 : 24.0;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Column(
              children: [
                const SizedBox(height: 80),

                // Animated score circle
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: 0, end: score / 100),
                  builder: (context, value, child) => SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                            value: value,
                            strokeWidth: 8,
                            backgroundColor: cs.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(
                              passed ? cs.tertiary : cs.error,
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(value * 100).toInt()}',
                              style: tt.displayLarge?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w300,
                                fontSize: 64,
                                height: 1,
                              ),
                            ),
                            Text(
                              'out of 100',
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: passed ? cs.tertiaryContainer : cs.errorContainer,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        passed ? Icons.check_circle : Icons.info,
                        size: 18,
                        color: passed ? cs.onTertiaryContainer : cs.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        passed ? 'Passed' : 'Not passed',
                        style: tt.labelLarge?.copyWith(
                          color: passed ? cs.onTertiaryContainer : cs.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  passed ? 'Well done!' : 'Keep trying',
                  style: tt.headlineLarge?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  passed
                      ? 'You passed the teaching assessment. Ready for the next step?'
                      : 'You need 60% to pass. You can retake this in 45 days.',
                  style: tt.bodyLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (!passed) const SizedBox(height: 32),

                if (!passed)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 20,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Next attempt in 45 days',
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),

        if (passed)
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
            child: FilledButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onContinue();
              },
              style: FilledButton.styleFrom(
                backgroundColor: cs.tertiary,
                foregroundColor: cs.onTertiary,
                minimumSize: const Size(double.infinity, 56),
                shape: const StadiumBorder(),
              ),
              child: const Text('Continue'),
            ),
          ),
      ],
    );
  }
}
