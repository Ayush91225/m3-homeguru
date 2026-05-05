import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../screens/dashboard/learner/learner_dashboard.dart';

class SuggestedTutors extends StatefulWidget {
  const SuggestedTutors({super.key});

  @override
  State<SuggestedTutors> createState() => _SuggestedTutorsState();
}

class _SuggestedTutorsState extends State<SuggestedTutors> {
  List<Map<String, dynamic>> _tutors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTutors();
  }

  Future<void> _loadTutors() async {
    try {
      final String response = await rootBundle.loadString('assets/mock_tutors.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        _tutors = [...data.take(5).map((e) => e as Map<String, dynamic>), {'isViewAll': true}];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (_isLoading) {
      return const SizedBox.shrink();
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
              Text(
                tutor['location'] ?? '',
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(width: 12),
              Icon(Icons.work_outline_rounded, size: 12, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                '${tutor['experience'] ?? 0} years exp',
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
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
