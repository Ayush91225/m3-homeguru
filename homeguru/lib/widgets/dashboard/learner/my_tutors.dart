import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../screens/shared/chat/chat_models.dart';
import '../../../screens/shared/chat/conversation_screen.dart';
import '../../../screens/shared/sessions_listing_screen.dart';

class MyTutors extends StatefulWidget {
  const MyTutors({super.key, this.showAll = false});
  final bool showAll;

  @override
  State<MyTutors> createState() => _MyTutorsState();
}

class _MyTutorsState extends State<MyTutors> {
  bool _isExpanded = false;
  String _selectedSubject = 'All';
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
        _tutors = data.map((e) => e as Map<String, dynamic>).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<String> get _allSubjects {
    final subjects = <String>{};
    for (final tutor in _tutors) {
      final tutorSubjects = tutor['subjects'] as List<dynamic>?;
      if (tutorSubjects != null) {
        for (final subject in tutorSubjects) {
          if (subject is Map<String, dynamic>) {
            final name = subject['name'];
            if (name != null) subjects.add(name.toString());
          }
        }
      }
    }
    final list = subjects.toList();
    list.sort();
    return list;
  }

  List<Map<String, dynamic>> get _filteredTutors {
    if (_selectedSubject == 'All') return _tutors;
    return _tutors.where((tutor) {
      final subjects = tutor['subjects'] as List<dynamic>?;
      if (subjects == null) return false;
      return subjects.any((s) {
        if (s is Map<String, dynamic>) {
          return s['name'] == _selectedSubject;
        }
        return false;
      });
    }).toList();
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
              Icon(Icons.people_rounded, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'My Tutors',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              _SubjectFilter(
                selectedSubject: _selectedSubject,
                subjects: _allSubjects,
                onSubjectChanged: (subject) {
                  setState(() => _selectedSubject = subject);
                },
                cs: cs,
              ),
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: widget.showAll
              ? _buildAllView(cs, tt)
              : _isExpanded
                  ? _buildExpandedView(cs, tt)
                  : _buildCollapsedView(cs, tt),
        ),
      ],
    );
  }

  Widget _buildAllView(ColorScheme cs, TextTheme tt) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        const spacing = 16.0;
        final itemWidth = (availableWidth - (3 * spacing)) / 4;
        final avatarSize = itemWidth.clamp(40.0, 56.0);

        return Column(
          children: List.generate((_filteredTutors.length / 4).ceil(), (rowIndex) {
            final startIndex = rowIndex * 4;
            final endIndex = (startIndex + 4).clamp(0, _filteredTutors.length);
            final rowTutors = _filteredTutors.sublist(startIndex, endIndex);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: rowTutors.asMap().entries.map((entry) => Padding(
                  padding: EdgeInsets.only(right: entry.key < rowTutors.length - 1 ? spacing : 0),
                  child: SizedBox(
                    width: itemWidth,
                    child: _TutorAvatar(tutor: entry.value, size: avatarSize),
                  ),
                )).toList(),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildCollapsedView(ColorScheme cs, TextTheme tt) {
    final displayTutors = _filteredTutors.take(3).toList();
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final spacing = 16.0;
        final itemWidth = (availableWidth - (3 * spacing)) / 4;
        final avatarSize = itemWidth.clamp(40.0, 56.0);
        
        return Row(
          children: [
            ...displayTutors.map((tutor) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: itemWidth,
                child: _TutorAvatar(tutor: tutor, size: avatarSize),
              ),
            )),
            if (_filteredTutors.length > 3)
              GestureDetector(
                onTap: () => setState(() => _isExpanded = true),
                child: SizedBox(
                  width: itemWidth,
                  child: Column(
                    children: [
                      Container(
                        width: avatarSize,
                        height: avatarSize,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          shape: BoxShape.circle,
                          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5), width: 2),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: cs.onSurfaceVariant,
                            size: avatarSize * 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'More',
                        style: tt.labelMedium?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildExpandedView(ColorScheme cs, TextTheme tt) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final spacing = 16.0;
        final itemWidth = (availableWidth - (3 * spacing)) / 4;
        final avatarSize = itemWidth.clamp(40.0, 56.0);
        
        return Column(
          children: [
            ...List.generate((_filteredTutors.length / 4).ceil(), (rowIndex) {
              final startIndex = rowIndex * 4;
              final endIndex = (startIndex + 4).clamp(0, _filteredTutors.length);
              final rowTutors = _filteredTutors.sublist(startIndex, endIndex);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    ...rowTutors.asMap().entries.map((entry) => Padding(
                      padding: EdgeInsets.only(right: entry.key < rowTutors.length - 1 ? spacing : 0),
                      child: SizedBox(
                        width: itemWidth,
                        child: _TutorAvatar(tutor: entry.value, size: avatarSize),
                      ),
                    )),
                  ],
                ),
              );
            }),
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = false),
                  child: SizedBox(
                    width: itemWidth,
                    child: Column(
                      children: [
                        Container(
                          width: avatarSize,
                          height: avatarSize,
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            shape: BoxShape.circle,
                            border: Border.all(color: cs.outline, width: 2),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.keyboard_arrow_up_rounded,
                              color: cs.onSurfaceVariant,
                              size: avatarSize * 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Less',
                          style: tt.labelMedium?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _TutorAvatar extends StatelessWidget {
  final Map<String, dynamic> tutor;
  final double size;

  const _TutorAvatar({required this.tutor, required this.size});

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _TutorDetailSheet(tutor: tutor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5), width: 2),
            ),
            child: ClipOval(
              child: Image.network(
                tutor['image'] ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: cs.surfaceContainer,
                  child: Icon(Icons.person, color: cs.onSurfaceVariant, size: size * 0.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: size,
            child: Text(
              (tutor['name'] ?? 'Unknown').split(' ')[0],
              style: tt.labelMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectFilter extends StatelessWidget {
  final String selectedSubject;
  final List<String> subjects;
  final Function(String) onSubjectChanged;
  final ColorScheme cs;

  const _SubjectFilter({
    required this.selectedSubject,
    required this.subjects,
    required this.onSubjectChanged,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(cs.surfaceContainer),
        elevation: const WidgetStatePropertyAll(3),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        maximumSize: const WidgetStatePropertyAll(Size(200, 300)),
      ),
      menuChildren: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MenuItemButton(
                  onPressed: () => onSubjectChanged('All'),
                  child: Text('All', style: TextStyle(color: cs.onSurface)),
                ),
                ...subjects.map((subject) => MenuItemButton(
                  onPressed: () => onSubjectChanged(subject),
                  child: Text(subject, style: TextStyle(color: cs.onSurface)),
                )),
              ],
            ),
          ),
        ),
      ],
      builder: (context, controller, child) {
        return SizedBox(
          height: 36,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primaryContainer,
                  foregroundColor: cs.onPrimaryContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(999),
                      bottomLeft: Radius.circular(999),
                    ),
                  ),
                  minimumSize: const Size(0, 36),
                  maximumSize: const Size(double.infinity, 36),
                ),
                child: Text(
                  selectedSubject,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: cs.onPrimaryContainer.withValues(alpha: 0.2),
              ),
              InkWell(
                onTap: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(999),
                  bottomRight: Radius.circular(999),
                ),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(999),
                      bottomRight: Radius.circular(999),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 18,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Tutor detail sheet ───────────────────────────────────────────────────────

class _TutorDetailSheet extends StatelessWidget {
  const _TutorDetailSheet({required this.tutor});
  final Map<String, dynamic> tutor;

  List<Map<String, dynamic>> get _subjects =>
      (tutor['subjects'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();

  int get _minRate => _subjects.isEmpty
      ? 0
      : _subjects.map((s) => s['hourlyRate'] as int? ?? 0).reduce((a, b) => a < b ? a : b);

  int get _maxRate => _subjects.isEmpty
      ? 0
      : _subjects.map((s) => s['hourlyRate'] as int? ?? 0).reduce((a, b) => a > b ? a : b);

  String get _rateLabel =>
      _minRate == _maxRate ? '₹$_minRate/hr' : '₹$_minRate–₹$_maxRate/hr';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final name = tutor['name'] as String? ?? 'Tutor';
    final image = tutor['image'] as String? ?? '';
    final verified = tutor['verified'] as bool? ?? false;
    final rating = (tutor['rating'] as num?)?.toDouble() ?? 0.0;
    final reviews = tutor['reviews'] as int? ?? 0;
    final experience = tutor['experience'] as int? ?? 0;
    final location = tutor['location'] as String? ?? '';
    final students = tutor['students'] as int? ?? 0;

    return Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // drag handle
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Avatar + name
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: cs.surfaceContainerHighest,
                  backgroundImage: NetworkImage(image),
                  onBackgroundImageError: (_, _) {},
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(name,
                                style: tt.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                          ),
                          if (verified) ...[
                            const SizedBox(width: 5),
                            Icon(Icons.verified_rounded,
                                size: 16, color: cs.primary),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.star_rounded,
                              size: 14, color: Colors.amber.shade600),
                          const SizedBox(width: 3),
                          Text('$rating',
                              style: tt.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          Text('  ·  $reviews reviews',
                              style: tt.bodySmall
                                  ?.copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                      if (location.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(location,
                            style: tt.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quick info chips
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _InfoChip(label: _rateLabel, cs: cs, tt: tt),
                _InfoChip(label: '${experience}y exp', cs: cs, tt: tt),
                _InfoChip(label: '$students students', cs: cs, tt: tt),
              ],
            ),
            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('Profile'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SessionsListingScreen(initialTutor: name),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('Sessions'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      final chatTutor = ChatTutor(
                        id: tutor['id']?.toString() ?? name,
                        name: name,
                        subject: _subjects.isNotEmpty
                            ? (_subjects.first['name'] as String? ?? '')
                            : '',
                        avatarUrl: image,
                        lastMessage: '',
                        time: '',
                        isVerified: verified,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConversationScreen(
                            tutor: chatTutor,
                            messages: [],
                          ),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('Message'),
                  ),
                ),
              ],
            ),

            if (_subjects.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 20),
              Text('Subjects',
                  style: tt.labelLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
              const SizedBox(height: 12),
              ..._subjects.map((s) {
                final subName = s['name'] as String? ?? '';
                final spec = s['specialization'] as String? ?? '';
                final rate = s['hourlyRate'] as int? ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(subName,
                                style: tt.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            if (spec.isNotEmpty)
                              Text(spec,
                                  style: tt.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Text('₹$rate/hr',
                          style: tt.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.primary)),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.cs, required this.tt});
  final String label;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant, fontWeight: FontWeight.w500)),
    );
  }
}
