import 'package:flutter/material.dart';

class TutorReviewsTab extends StatelessWidget {
  const TutorReviewsTab({super.key, this.viewMode = false});
  
  final bool viewMode;

  static const _reviews = [
    {
      'name': 'Rahul Verma',
      'avatar': 'R',
      'rating': 5.0,
      'date': '2 days ago',
      'subject': 'Mathematics',
      'comment': 'Excellent tutor! Explains concepts very clearly and patiently. My math scores improved significantly after taking sessions.',
    },
    {
      'name': 'Priya Singh',
      'avatar': 'P',
      'rating': 5.0,
      'date': '1 week ago',
      'subject': 'Physics',
      'comment': 'Very knowledgeable and helpful. Makes difficult physics topics easy to understand. Highly recommended!',
    },
    {
      'name': 'Amit Kumar',
      'avatar': 'A',
      'rating': 4.0,
      'date': '2 weeks ago',
      'subject': 'Mathematics',
      'comment': 'Good teaching style and very punctual. Would have given 5 stars if there were more practice problems.',
    },
    {
      'name': 'Sneha Patel',
      'avatar': 'S',
      'rating': 5.0,
      'date': '3 weeks ago',
      'subject': 'JEE Preparation',
      'comment': 'Best tutor for JEE prep! Focuses on problem-solving techniques and shortcuts. Very helpful for competitive exams.',
    },
    {
      'name': 'Vikram Sharma',
      'avatar': 'V',
      'rating': 4.0,
      'date': '1 month ago',
      'subject': 'Physics',
      'comment': 'Great explanations and good command over the subject. Sessions are well-structured and productive.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        const SizedBox(height: 20),
        _RatingSummary(cs: cs, tt: tt),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            '${_reviews.length} reviews',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        ..._reviews.map((review) => _ReviewCard(
          name: review['name'] as String,
          avatar: review['avatar'] as String,
          rating: review['rating'] as double,
          date: review['date'] as String,
          subject: review['subject'] as String,
          comment: review['comment'] as String,
          cs: cs,
          tt: tt,
        )),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _RatingSummary extends StatelessWidget {
  const _RatingSummary({required this.cs, required this.tt});
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  '4.8',
                  style: tt.displayMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) => Icon(
                    Icons.star_rounded,
                    color: cs.tertiary,
                    size: 20,
                  )),
                ),
                const SizedBox(height: 8),
                Text(
                  '156 reviews',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _RatingBar(stars: 5, count: 128, total: 156, cs: cs, tt: tt),
                _RatingBar(stars: 4, count: 22, total: 156, cs: cs, tt: tt),
                _RatingBar(stars: 3, count: 4, total: 156, cs: cs, tt: tt),
                _RatingBar(stars: 2, count: 2, total: 156, cs: cs, tt: tt),
                _RatingBar(stars: 1, count: 0, total: 156, cs: cs, tt: tt),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  const _RatingBar({
    required this.stars,
    required this.count,
    required this.total,
    required this.cs,
    required this.tt,
  });
  final int stars, count, total;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? count / total : 0.0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 8,
            child: Text(
              '$stars',
              style: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.star_rounded, size: 14, color: cs.tertiary),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: cs.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation(cs.tertiary),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.name,
    required this.avatar,
    required this.rating,
    required this.date,
    required this.subject,
    required this.comment,
    required this.cs,
    required this.tt,
  });
  final String name, avatar, date, subject, comment;
  final double rating;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: cs.tertiaryContainer,
                child: Text(
                  avatar,
                  style: tt.titleMedium?.copyWith(
                    color: cs.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(date, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...List.generate(5, (i) => Icon(
                i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 16,
                color: cs.tertiary,
              )),
              const SizedBox(width: 8),
              Text(
                subject,
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment,
            style: tt.bodyMedium?.copyWith(color: cs.onSurface, height: 1.5),
          ),
        ],
      ),
    );
  }
}
