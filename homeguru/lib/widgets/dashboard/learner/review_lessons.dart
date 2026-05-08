import 'package:flutter/material.dart';
import '../../../screens/shared/class_content_screen.dart';
import '../../../screens/shared/sessions_listing_screen.dart';

class ReviewLessons extends StatelessWidget {
  const ReviewLessons({super.key});

  List<Map<String, dynamic>> _generateTodaySessions() {
    final now = DateTime.now();
    return [
      {
        'title': 'English Speaking Practice',
        'subject': 'IELTS',
        'tutor': 'Vikram Singh',
        'tutorImage': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop',
        'completedAt': now.subtract(const Duration(hours: 2)),
        'files': 3,
        'quiz': '6/15',
        'duration': '1h 30m',
      },
      {
        'title': 'Mathematics Problem Solving',
        'subject': 'JEE Advanced',
        'tutor': 'Priya Sharma',
        'tutorImage': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop',
        'completedAt': now.subtract(const Duration(hours: 5)),
        'files': 2,
        'quiz': '8/10',
        'duration': '1h 15m',
      },
      {
        'title': 'Chemistry Organic Compounds',
        'subject': 'CBSE Grade 11-12',
        'tutor': 'Ananya Reddy',
        'tutorImage': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop',
        'completedAt': now.subtract(const Duration(hours: 8)),
        'files': 4,
        'quiz': '12/15',
        'duration': '2h 00m',
      },
      {
        'title': 'Biology Cell Structure',
        'subject': 'NEET',
        'tutor': 'Meera Patel',
        'tutorImage': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop',
        'completedAt': now.subtract(const Duration(hours: 10)),
        'files': 5,
        'quiz': '14/20',
        'duration': '1h 45m',
      },
      {
        'title': 'Physics Mechanics',
        'subject': 'JEE Mains',
        'tutor': 'Rajesh Kumar',
        'tutorImage': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
        'completedAt': now.subtract(const Duration(hours: 12)),
        'files': 3,
        'quiz': '9/12',
        'duration': '1h 30m',
      },
      {'isViewAll': true},
    ];
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inHours < 1) return '${diff.inMinutes}min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final sessions = _generateTodaySessions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Icon(Icons.attach_file_rounded, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Review Today\'s Lessons',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: CarouselView.weighted(
            flexWeights: const [3, 2, 1],
            itemSnapping: true,
            padding: EdgeInsets.zero,
            onTap: (index) {
              final s = sessions[index];
              if (s['isViewAll'] == true) {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const SessionsListingScreen(),
                ));
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClassContentScreen(session: s),
                ),
              );
            },
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(28)),
            ),
            children: sessions.map((session) {
              if (session['isViewAll'] == true) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final isSmall = w < 100;
                    final isMedium = w < 200;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _ViewAllCard(isSmall: isSmall, isMedium: isMedium),
                    );
                  },
                );
              }
              return LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final isSmall = w < 100;
                  final isMedium = w < 200;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _LessonCard(
                      session: session,
                      isSmall: isSmall,
                      isMedium: isMedium,
                      getTimeAgo: _getTimeAgo,
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Map<String, dynamic> session;
  final bool isSmall;
  final bool isMedium;
  final String Function(DateTime) getTimeAgo;

  const _LessonCard({
    required this.session,
    required this.isSmall,
    required this.isMedium,
    required this.getTimeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (isSmall) {
      return Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Icon(
            Icons.school_rounded,
            size: 32,
            color: cs.onSurfaceVariant,
          ),
        ),
      );
    }

    if (isMedium) {
      return Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cs.tertiaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                getTimeAgo(session['completedAt']),
                style: tt.labelSmall?.copyWith(
                  color: cs.onTertiaryContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: 9,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                session['title'],
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: cs.surfaceContainer,
                  backgroundImage: NetworkImage(session['tutorImage']),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    session['tutor'],
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: null,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                minimumSize: const Size(double.infinity, 28),
              ),
              child: Text(
                'Review',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: cs.tertiaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        getTimeAgo(session['completedAt']),
                        style: tt.labelSmall?.copyWith(
                          color: cs.onTertiaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.attach_file_rounded, size: 12, color: cs.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            'Files (${session['files']})',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${session['quiz']} Quiz',
                        style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      session['title'],
                      style: tt.bodyLarge?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      session['subject'],
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: cs.surfaceContainer,
                          backgroundImage: NetworkImage(session['tutorImage']),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'by ${session['tutor']}',
                            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          session['duration'],
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_outline_rounded, size: 16, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        'Rate',
                        style: tt.labelSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Flexible(
                    child: OutlinedButton(
                      onPressed: null,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                      child: Text(
                        'Review',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ViewAllCard extends StatelessWidget {
  final bool isSmall;
  final bool isMedium;

  const _ViewAllCard({required this.isSmall, required this.isMedium});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_edu_rounded,
              size: isSmall ? 24 : (isMedium ? 28 : 32),
              color: cs.onSurfaceVariant,
            ),
            if (!isSmall) ...[
              const SizedBox(height: 12),
              Text(
                'View All Lessons',
                style: (isMedium ? tt.bodyMedium : tt.bodyLarge)?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
