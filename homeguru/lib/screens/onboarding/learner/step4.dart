import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LearnerStep4Body extends StatefulWidget {
  const LearnerStep4Body({
    super.key,
    required this.interest,
    required this.onNext,
  });

  final String interest; // 'academic' | 'non_academic'
  final void Function(String subject) onNext;

  @override
  State<LearnerStep4Body> createState() => _LearnerStep4BodyState();
}

class _LearnerStep4BodyState extends State<LearnerStep4Body> {
  final Set<String> _selected = {};

  static const _academic = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Science',
    'English',
    'Hindi',
    'Sanskrit',
    'Social Studies',
    'History',
    'Geography',
    'Political Science',
    'Economics',
    'Accountancy',
    'Business Studies',
    'Computer Science',
    'Statistics',
    'Psychology',
    'Sociology',
    'Environmental Science',
    'Physical Education',
    'Others',
  ];

  static const _nonAcademic = [
    'Music — Vocals',
    'Music — Guitar',
    'Music — Piano',
    'Music — Tabla',
    'Dance — Classical',
    'Dance — Western',
    'Dance — Bollywood',
    'Art & Design',
    'Sketching & Drawing',
    'Painting',
    'Photography',
    'Videography',
    'Coding',
    'Web Development',
    'App Development',
    'Spoken English',
    'Foreign Languages',
    'Public Speaking',
    'Creative Writing',
    'Yoga & Fitness',
    'Cooking & Baking',
    'Chess',
    'Others',
  ];

  static const _maxSelection = 5;

  List<String> get _subjects =>
      widget.interest == 'academic' ? _academic : _nonAcademic;

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
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _subjects.map((subject) {
                final selected = _selected.contains(subject);
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (_selected.contains(subject)) {
                        _selected.remove(subject);
                      } else if (_selected.length < _maxSelection) {
                        _selected.add(subject);
                      } else {
                        HapticFeedback.heavyImpact();
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? cs.primaryContainer
                          : (!selected && _selected.length >= _maxSelection)
                              ? cs.surfaceContainerLow.withValues(alpha: 0.5)
                              : cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: selected ? cs.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      subject,
                      style: tt.bodyMedium?.copyWith(
                        color: selected
                            ? cs.onPrimaryContainer
                            : cs.onSurface,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select up to $_maxSelection subjects',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              Text(
                '${_selected.length}/$_maxSelection',
                style: tt.labelSmall?.copyWith(
                  color: _selected.length >= _maxSelection ? cs.primary : cs.onSurfaceVariant,
                  fontWeight: _selected.length >= _maxSelection ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 16),
          child: FilledButton(
            onPressed: _selected.isEmpty
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    widget.onNext(_selected.join(','));
                  },
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }
}
