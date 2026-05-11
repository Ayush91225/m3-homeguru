import 'package:flutter/material.dart';

class TutorReviewsTab extends StatelessWidget {
  const TutorReviewsTab({super.key, this.viewMode = false});

  final bool viewMode;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        const SizedBox(height: 60),
        Center(
          child: Column(
            children: [
              Icon(Icons.rate_review_outlined, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
              const SizedBox(height: 12),
              Text('No reviews yet', style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(
                viewMode ? 'This tutor has no reviews yet.' : 'Reviews from your students will appear here.',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
