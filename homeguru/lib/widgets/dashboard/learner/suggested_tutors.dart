import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../screens/dashboard/learner/learner_dashboard.dart';
import '../../shared/tutor_action_sheet.dart';
import '../../../services/learner_data_model.dart';

class SuggestedTutors extends StatefulWidget {
  const SuggestedTutors({super.key});

  @override
  State<SuggestedTutors> createState() => _SuggestedTutorsState();
}

class _SuggestedTutorsState extends State<SuggestedTutors> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Map<String, dynamic>> _tutors = [];
  bool _isLoading = true;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadTutors();
  }

  Future<void> _loadTutors() async {
    if (_hasLoaded) return;
    final result = await LearnerDataModel.fetchTutors(limit: 6);
    final apiTutors = result['tutors'] as List<Map<String, dynamic>>;
    if (!mounted) return;
    setState(() {
      _hasLoaded = true;
      if (apiTutors.isEmpty) {
        _tutors = [];
      } else {
        _tutors = [
          ...apiTutors.map((t) => LearnerDataModel.mapTutorForWidget(t)),
          {'isViewAll': true}
        ];
      }
      _isLoading = false;
    });
  }

  String _getSubjects(Map<String, dynamic> tutor) {
    final subjects = tutor['subjects'] as List<dynamic>?;
    if (subjects == null || subjects.isEmpty) return '';
    if (subjects.length == 1) {
      return (subjects[0] as Map<String, dynamic>)['name'] ?? '';
    }
    return '${subjects.length} subjects';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Row(
              children: [
                Icon(Icons.recommend_rounded, size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  'Suggested Tutors',
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
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => SizedBox(
                width: 280,
                child: _ShimmerTutorCard(cs: cs),
              ),
            ),
          ),
        ],
      );
    }

    if (_tutors.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Row(
              children: [
                Icon(Icons.recommend_rounded, size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  'Suggested Tutors',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Column(children: [
              Icon(Icons.person_search_rounded, size: 36, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
              const SizedBox(height: 8),
              Text('No tutors available', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ]),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Icon(Icons.recommend_rounded, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Suggested Tutors',
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
              if (index == _tutors.length - 1) {
                final dashboardState = context.findAncestorStateOfType<LearnerDashboardState>();
                if (dashboardState != null) {
                  dashboardState.onItemTapped(1);
                }
              } else {
                final tutor = _tutors[index];
                HapticFeedback.lightImpact();
                TutorActionSheet.show(
                  context,
                  tutorId: tutor['id'] ?? '',
                  tutorName: tutor['name'] ?? '',
                  tutorImage: tutor['image'] ?? '',
                  isVerified: tutor['verified'] == true,
                  primarySubject: _getSubjects(tutor),
                  tutorRating: (tutor['rating'] as num?)?.toDouble() ?? 0,
                  tutorStudents: tutor['students'] as int? ?? 0,
                  tutorLocation: tutor['location'] ?? '',
                  tutorPricing: {
                    for (var subject in (tutor['subjects'] as List<dynamic>? ?? []))
                      (subject as Map<String, dynamic>)['name'] as String:
                          subject['hourlyRate'] as int
                  },
                  tutorRates: tutor['rates'] as List? ?? [],
                  tutorLanguages: tutor['languages'] as List? ?? [],
                  tutorAvailability: tutor['availability'] as List? ?? [],
                );
              }
            },
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(28)),
            ),
            children: _tutors.map((tutor) {
              if (tutor['isViewAll'] == true) {
                return LayoutBuilder(
                  builder: (builderContext, constraints) {
                    final w = constraints.maxWidth;
                    final isSmall = w < 100;
                    final isMedium = w < 200;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _ViewAllCard(
                        isSmall: isSmall,
                        isMedium: isMedium,
                      ),
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
                    child: _TutorCard(
                      tutor: tutor,
                      isSmall: isSmall,
                      isMedium: isMedium,
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

class _TutorCard extends StatelessWidget {
  final Map<String, dynamic> tutor;
  final bool isSmall;
  final bool isMedium;

  const _TutorCard({
    required this.tutor,
    required this.isSmall,
    required this.isMedium,
  });

  String _getSubjects() {
    final rates = tutor['rates'] as List<dynamic>?;
    if (rates != null && rates.isNotEmpty) {
      final rate = rates[0] as Map<String, dynamic>;
      final subject = rate['subject']?.toString() ?? '';
      final board = rate['board']?.toString() ?? '';
      final grade = rate['grade']?.toString() ?? '';
      if (board.isNotEmpty) {
        return '$subject • $board • $grade';
      }
      return subject;
    }
    final subjects = tutor['subjects'] as List<dynamic>?;
    if (subjects == null || subjects.isEmpty) return '';
    if (subjects.length == 1) {
      return (subjects[0] as Map<String, dynamic>)['name'] ?? '';
    }
    return '${subjects.length} subjects';
  }

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
            Icons.person_rounded,
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
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: cs.surfaceContainer,
                      backgroundImage: NetworkImage(tutor['image'] ?? ''),
                    ),
                    if (tutor['verified'] == true)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.verified_rounded, size: 10, color: cs.primary),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tutor['name'] ?? 'Unknown',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, size: 10, color: Colors.amber),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              '${tutor['rating'] ?? 0}',
                              style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontSize: 9,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getSubjects(),
              style: tt.labelSmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                tutor['location'] ?? '',
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 9,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                backgroundColor: cs.primaryContainer,
                foregroundColor: cs.onPrimaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                minimumSize: const Size(double.infinity, 28),
              ),
              child: Text(
                'Book',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: cs.onPrimaryContainer,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: cs.surfaceContainer,
                    backgroundImage: NetworkImage(tutor['image'] ?? ''),
                  ),
                  if (tutor['verified'] == true)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.verified_rounded, size: 14, color: cs.primary),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutor['name'] ?? 'Unknown',
                      style: tt.bodyLarge?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${tutor['rating'] ?? 0}',
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${tutor['reviews'] ?? 0} reviews)',
                          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: cs.secondaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _getSubjects(),
              style: tt.labelSmall?.copyWith(
                color: cs.onSecondaryContainer,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 12, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  tutor['location']?.toString() ?? '',
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if ((tutor['languages'] as List?)?.isNotEmpty == true)
            Row(
              children: [
                Icon(Icons.language_rounded, size: 12, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    (tutor['languages'] as List).map((l) => l is Map ? l['name'] ?? '' : l.toString()).take(2).join(', '),
                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Icon(Icons.work_outline_rounded, size: 12, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    tutor['experience']?.toString() ?? 'New tutor',
                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.people_outline_rounded, size: 12, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                '${tutor['students'] ?? 0} students',
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(width: 12),
              Icon(Icons.access_time_rounded, size: 12, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                tutor['responseTime'] ?? '',
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const Spacer(),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: cs.primaryContainer,
              foregroundColor: cs.onPrimaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              minimumSize: const Size(double.infinity, 36),
            ),
            child: Text(
              'Book Session',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: cs.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerTutorCard extends StatefulWidget {
  final ColorScheme cs;
  const _ShimmerTutorCard({required this.cs});

  @override
  State<_ShimmerTutorCard> createState() => _ShimmerTutorCardState();
}

class _ShimmerTutorCardState extends State<_ShimmerTutorCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.cs;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? cs.surfaceContainerHigh : cs.surfaceContainer;
    final highlightColor = isDark ? cs.surfaceContainerHighest : cs.surfaceContainerHigh;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (_, _) => Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: [
                        (_animation.value - 0.5).clamp(0.0, 1.0),
                        _animation.value.clamp(0.0, 1.0),
                        (_animation.value + 0.5).clamp(0.0, 1.0),
                      ],
                      colors: [baseColor, highlightColor, baseColor],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (_, _) => Container(
                        width: double.infinity,
                        height: 14,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: [
                              (_animation.value - 0.5).clamp(0.0, 1.0),
                              _animation.value.clamp(0.0, 1.0),
                              (_animation.value + 0.5).clamp(0.0, 1.0),
                            ],
                            colors: [baseColor, highlightColor, baseColor],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (_, _) => Container(
                        width: 60,
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: [
                              (_animation.value - 0.5).clamp(0.0, 1.0),
                              _animation.value.clamp(0.0, 1.0),
                              (_animation.value + 0.5).clamp(0.0, 1.0),
                            ],
                            colors: [baseColor, highlightColor, baseColor],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _animation,
            builder: (_, _) => Container(
              width: 100,
              height: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [
                    (_animation.value - 0.5).clamp(0.0, 1.0),
                    _animation.value.clamp(0.0, 1.0),
                    (_animation.value + 0.5).clamp(0.0, 1.0),
                  ],
                  colors: [baseColor, highlightColor, baseColor],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _animation,
            builder: (_, _) => Container(
              width: double.infinity,
              height: 10,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [
                    (_animation.value - 0.5).clamp(0.0, 1.0),
                    _animation.value.clamp(0.0, 1.0),
                    (_animation.value + 0.5).clamp(0.0, 1.0),
                  ],
                  colors: [baseColor, highlightColor, baseColor],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedBuilder(
            animation: _animation,
            builder: (_, _) => Container(
              width: 120,
              height: 10,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [
                    (_animation.value - 0.5).clamp(0.0, 1.0),
                    _animation.value.clamp(0.0, 1.0),
                    (_animation.value + 0.5).clamp(0.0, 1.0),
                  ],
                  colors: [baseColor, highlightColor, baseColor],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const Spacer(),
          AnimatedBuilder(
            animation: _animation,
            builder: (_, _) => Container(
              width: double.infinity,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [
                    (_animation.value - 0.5).clamp(0.0, 1.0),
                    _animation.value.clamp(0.0, 1.0),
                    (_animation.value + 0.5).clamp(0.0, 1.0),
                  ],
                  colors: [baseColor, highlightColor, baseColor],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewAllCard extends StatelessWidget {
  final bool isSmall;
  final bool isMedium;

  const _ViewAllCard({
    required this.isSmall,
    required this.isMedium,
  });

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
              Icons.explore_rounded,
              size: isSmall ? 24 : (isMedium ? 28 : 32),
              color: cs.onSurfaceVariant,
            ),
            if (!isSmall) ...[
              const SizedBox(height: 12),
              Text(
                'View All Tutors',
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
