import 'package:flutter/material.dart';

class TutorCard extends StatelessWidget {
  final Map<String, dynamic> tutor;
  final VoidCallback? onTap;
  final bool isTopLeft;
  final bool isTopRight;
  final bool isBottomLeft;
  final bool isBottomRight;

  const TutorCard({
    super.key,
    required this.tutor,
    this.onTap,
    this.isTopLeft = false,
    this.isTopRight = false,
    this.isBottomLeft = false,
    this.isBottomRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final subjects = tutor['subjects'] as List<dynamic>;
    final primarySubject = subjects[0];
    final lowestRate = subjects.length > 1
        ? subjects.map<int>((s) => s['hourlyRate'] as int).reduce((a, b) => a < b ? a : b)
        : primarySubject['hourlyRate'] as int;

    BorderRadius? borderRadius;
    if (isTopLeft) {
      borderRadius = const BorderRadius.only(topLeft: Radius.circular(16));
    } else if (isTopRight) {
      borderRadius = const BorderRadius.only(topRight: Radius.circular(16));
    } else if (isBottomLeft) {
      borderRadius = const BorderRadius.only(bottomLeft: Radius.circular(16));
    } else if (isBottomRight) {
      borderRadius = const BorderRadius.only(bottomRight: Radius.circular(16));
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: borderRadius,
        ),
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Image.network(
                      tutor['image'],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      cacheWidth: 300,
                      cacheHeight: 300,
                      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded) return child;
                        return frame != null ? child : Container(color: cs.surfaceContainerHigh);
                      },
                      errorBuilder: (_, _, _) => Container(color: cs.primaryContainer),
                    ),

                    // Rating badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              tutor['rating'].toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Verified badge
                    if (tutor['verified'] == true)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.verified,
                            size: 14,
                            color: cs.onPrimary,
                          ),
                        ),
                      ),
                    // Price tag
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          subjects.length > 1 ? 'From ₹$lowestRate/hr' : '₹${primarySubject['hourlyRate']}/hr',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: cs.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Info section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tutor['name'],
                            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            primarySubject['name'] ?? '',
                            style: tt.bodySmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subjects.length > 1)
                            Text(
                              '+${subjects.length - 1} more',
                              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 10),
                            ),
                        ],
                      ),
                      Text(
                        '${tutor['experience']}y exp',
                        style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
