import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'step4_data.dart';
import '../../../services/tutor_onboarding_service.dart';
import '../../../models/tutor_onboarding_model.dart';

class TutorStep4Body extends StatefulWidget {
  const TutorStep4Body({super.key, required this.onNext});
  final void Function(Map<String, dynamic> subjects) onNext;

  @override
  State<TutorStep4Body> createState() => _TutorStep4BodyState();
}

class _TutorStep4BodyState extends State<TutorStep4Body> {
  // Teaching levels selected
  final Set<String> _levels = {};

  // Schooling
  final Set<String> _boards = {};
  final Set<String> _classGroups = {};
  // board → grade → subjects
  final Map<String, Map<String, Set<String>>> _schoolSubjects = {};

  // Competitive exams: category → exams
  final Map<String, Set<String>> _compExams = {};

  // Study abroad
  final Set<String> _studyAbroadExams = {};

  // Non-academic
  final Set<String> _nonAcademic = {};
  final Map<String, Set<String>> _musicTypes = {}; // type → instruments
  final Set<String> _danceStyles = {};
  final Set<String> _codingCourses = {};

  // Language learning
  final Set<String> _foreignLangs = {};
  final Set<String> _regionalLangs = {};

  bool get _hasSelection {
    if (_levels.isEmpty) return false;

    // Schooling deep validation
    if (_levels.contains('Schooling')) {
      if (_boards.isEmpty || _classGroups.isEmpty) return false;
      for (final board in _boards) {
        for (final group in _classGroups) {
          final subjects = _schoolSubjects[board]?[group];
          if (subjects == null || subjects.isEmpty) return false;
        }
      }
    }

    // Competitive Exams deep validation
    if (_levels.contains('Competitive Exams') || _levels.contains('Olympiad')) {
      bool hasExam = false;
      for (final exams in _compExams.values) {
        if (exams.isNotEmpty) {
          hasExam = true;
          break;
        }
      }
      if (!hasExam) return false;
    }

    // Study Abroad
    if (_levels.contains('Study Abroad') && _studyAbroadExams.isEmpty) return false;

    // Non-Academic deep validation
    if (_levels.contains('Non-Academic')) {
      if (_nonAcademic.isEmpty) return false;
      if (_nonAcademic.contains('Music')) {
        bool hasInstrument = false;
        for (final insts in _musicTypes.values) {
          if (insts.isNotEmpty) {
            hasInstrument = true;
            break;
          }
        }
        if (!hasInstrument) return false;
      }
      if (_nonAcademic.contains('Dance') && _danceStyles.isEmpty) return false;
      if (_nonAcademic.contains('Coding & Computers') && _codingCourses.isEmpty) return false;
    }

    // Language Learning
    if (_levels.contains('Language Learning') && _foreignLangs.isEmpty && _regionalLangs.isEmpty) return false;

    return true;
  }

  void _submit() async {
    HapticFeedback.mediumImpact();
    
    // Get tutorId from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final tutorId = prefs.getString('tutorId');
    
    if (tutorId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired. Please start over.')),
        );
      }
      return;
    }
    
    // Save to API
    final tutorData = TutorOnboarding();
    tutorData.tutorId = tutorId;
    tutorData.set('levels', _levels.toList());
    tutorData.set('boards', _boards.toList());
    tutorData.set('classGroups', _classGroups.toList());
    tutorData.set('schoolSubjects', _schoolSubjects.map((b, g) => MapEntry(b, g.map((gr, s) => MapEntry(gr, s.toList())))));
    tutorData.set('competitiveExams', _compExams.map((k, v) => MapEntry(k, v.toList())));
    tutorData.set('studyAbroadExams', _studyAbroadExams.toList());
    tutorData.set('nonAcademic', _nonAcademic.toList());
    tutorData.set('musicTypes', _musicTypes.map((k, v) => MapEntry(k, v.toList())));
    tutorData.set('danceStyles', _danceStyles.toList());
    tutorData.set('codingCourses', _codingCourses.toList());
    tutorData.set('foreignLanguages', _foreignLangs.toList());
    tutorData.set('regionalLanguages', _regionalLangs.toList());
    
    final result = await TutorOnboardingService.updateSubjects(tutorId, tutorData);
    
    if (result['success'] == true) {
      widget.onNext({
        'levels': _levels.toList(),
        'boards': _boards.toList(),
        'classGroups': _classGroups.toList(),
        'schoolSubjects': _schoolSubjects.map((b, g) => MapEntry(b, g.map((gr, s) => MapEntry(gr, s.toList())))),
        'competitiveExams': _compExams.map((k, v) => MapEntry(k, v.toList())),
        'studyAbroadExams': _studyAbroadExams.toList(),
        'nonAcademic': _nonAcademic.toList(),
        'musicTypes': _musicTypes.map((k, v) => MapEntry(k, v.toList())),
        'danceStyles': _danceStyles.toList(),
        'codingCourses': _codingCourses.toList(),
        'foreignLanguages': _foreignLangs.toList(),
        'regionalLanguages': _regionalLangs.toList(),
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Failed to save subjects')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= 600 ? w * 0.2 : 20.0;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Teaching levels ──────────────────────────────────────
                _SectionCard(
                  cs: cs, tt: tt,
                  title: 'Teaching levels',
                  subtitle: 'Select all that apply',
                  child: _ChipWrap(
                    options: kTeachingLevels,
                    selected: _levels,
                    cs: cs, tt: tt,
                    onTap: (v) => setState(() => _levels.contains(v) ? _levels.remove(v) : _levels.add(v)),
                  ),
                ),

                // ── Schooling ────────────────────────────────────────────
                if (_levels.contains('Schooling')) ...[
                  const SizedBox(height: 16),
                  _SectionCard(cs: cs, tt: tt, title: 'Boards', subtitle: 'Which boards do you teach?',
                    child: _ChipWrap(options: kBoards, selected: _boards, cs: cs, tt: tt,
                      onTap: (v) => setState(() => _boards.contains(v) ? _boards.remove(v) : _boards.add(v)),
                    ),
                  ),
                  if (_boards.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _SectionCard(cs: cs, tt: tt, title: 'Class groups', subtitle: 'Which grades do you teach?',
                      child: _ChipWrap(options: kClassGroups, selected: _classGroups, cs: cs, tt: tt,
                        onTap: (v) => setState(() => _classGroups.contains(v) ? _classGroups.remove(v) : _classGroups.add(v)),
                      ),
                    ),
                    // Per board + grade subject picker
                    for (final board in _boards)
                      for (final group in _classGroups) ...[
                        const SizedBox(height: 16),
                        _SubjectPicker(
                          cs: cs, tt: tt,
                          board: board,
                          group: group,
                          selected: _schoolSubjects[board]?[group] ?? {},
                          onChanged: (subjects) => setState(() {
                            _schoolSubjects[board] ??= {};
                            _schoolSubjects[board]![group] = subjects;
                          }),
                        ),
                      ],
                  ],
                ],

                // ── Competitive Exams ────────────────────────────────────
                if (_levels.contains('Competitive Exams') || _levels.contains('Olympiad')) ...[
                  const SizedBox(height: 16),
                  _SectionCard(cs: cs, tt: tt, title: 'Competitive exams', subtitle: 'Pick categories and specific exams',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: kCompetitiveExams.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Text(entry.key, style: tt.labelMedium?.copyWith(color: cs.tertiary, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                            const SizedBox(height: 8),
                            _ChipWrap(
                              options: entry.value,
                              selected: _compExams[entry.key] ?? {},
                              cs: cs, tt: tt,
                              onTap: (v) => setState(() {
                                _compExams[entry.key] ??= {};
                                _compExams[entry.key]!.contains(v) ? _compExams[entry.key]!.remove(v) : _compExams[entry.key]!.add(v);
                              }),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],

                // ── Study Abroad ─────────────────────────────────────────
                if (_levels.contains('Study Abroad')) ...[
                  const SizedBox(height: 16),
                  _SectionCard(cs: cs, tt: tt, title: 'Study abroad exams', subtitle: 'Which exams do you coach for?',
                    child: _ChipWrap(options: kStudyAbroadExams, selected: _studyAbroadExams, cs: cs, tt: tt,
                      onTap: (v) => setState(() => _studyAbroadExams.contains(v) ? _studyAbroadExams.remove(v) : _studyAbroadExams.add(v)),
                    ),
                  ),
                ],

                // ── Non-Academic ─────────────────────────────────────────
                if (_levels.contains('Non-Academic')) ...[
                  const SizedBox(height: 16),
                  _SectionCard(cs: cs, tt: tt, title: 'Non-academic activities', subtitle: 'Select what you teach',
                    child: _ChipWrap(options: kNonAcademicActivities, selected: _nonAcademic, cs: cs, tt: tt,
                      onTap: (v) => setState(() => _nonAcademic.contains(v) ? _nonAcademic.remove(v) : _nonAcademic.add(v)),
                    ),
                  ),
                  if (_nonAcademic.contains('Music')) ...[
                    const SizedBox(height: 16),
                    _SectionCard(cs: cs, tt: tt, title: 'Music — types & instruments', subtitle: 'Select all you teach',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: kMusicTypes.entries.map((entry) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Text(entry.key, style: tt.labelMedium?.copyWith(color: cs.tertiary, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            _ChipWrap(options: entry.value, selected: _musicTypes[entry.key] ?? {}, cs: cs, tt: tt,
                              onTap: (v) => setState(() {
                                _musicTypes[entry.key] ??= {};
                                _musicTypes[entry.key]!.contains(v) ? _musicTypes[entry.key]!.remove(v) : _musicTypes[entry.key]!.add(v);
                              }),
                            ),
                          ],
                        )).toList(),
                      ),
                    ),
                  ],
                  if (_nonAcademic.contains('Dance')) ...[
                    const SizedBox(height: 16),
                    _SectionCard(cs: cs, tt: tt, title: 'Dance styles', subtitle: 'Select all you teach',
                      child: _ChipWrap(options: kDanceStyles, selected: _danceStyles, cs: cs, tt: tt,
                        onTap: (v) => setState(() => _danceStyles.contains(v) ? _danceStyles.remove(v) : _danceStyles.add(v)),
                      ),
                    ),
                  ],
                  if (_nonAcademic.contains('Coding & Computers')) ...[
                    const SizedBox(height: 16),
                    _SectionCard(cs: cs, tt: tt, title: 'Coding & computer courses', subtitle: 'Select all you teach',
                      child: _ChipWrap(options: kCodingCourses, selected: _codingCourses, cs: cs, tt: tt,
                        onTap: (v) => setState(() => _codingCourses.contains(v) ? _codingCourses.remove(v) : _codingCourses.add(v)),
                      ),
                    ),
                  ],
                ],

                // ── Language Learning ────────────────────────────────────
                if (_levels.contains('Language Learning')) ...[
                  const SizedBox(height: 16),
                  _SectionCard(cs: cs, tt: tt, title: 'Foreign languages', subtitle: 'Which foreign languages do you teach?',
                    child: _ChipWrap(options: kForeignLanguages, selected: _foreignLangs, cs: cs, tt: tt,
                      onTap: (v) => setState(() => _foreignLangs.contains(v) ? _foreignLangs.remove(v) : _foreignLangs.add(v)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(cs: cs, tt: tt, title: 'Regional languages', subtitle: 'Which regional languages do you teach?',
                    child: _ChipWrap(options: kRegionalLanguages, selected: _regionalLangs, cs: cs, tt: tt,
                      onTap: (v) => setState(() => _regionalLangs.contains(v) ? _regionalLangs.remove(v) : _regionalLangs.add(v)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
          child: Column(
            children: [
              if (_levels.isNotEmpty && !_hasSelection)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Please select subjects/topics for all categories',
                    style: tt.labelSmall?.copyWith(color: cs.error),
                  ),
                ),
              FilledButton(
                onPressed: _hasSelection ? _submit : null,
                style: FilledButton.styleFrom(
                  backgroundColor: cs.tertiary,
                  foregroundColor: cs.onTertiary,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subject picker per board + grade group
// ─────────────────────────────────────────────────────────────────────────────

class _SubjectPicker extends StatelessWidget {
  const _SubjectPicker({required this.cs, required this.tt, required this.board, required this.group, required this.selected, required this.onChanged});
  final ColorScheme cs;
  final TextTheme tt;
  final String board;
  final String group;
  final Set<String> selected;
  final void Function(Set<String>) onChanged;

  List<String> get _subjects {
    final map = switch (board) {
      'CBSE'        => kCbseSubjects,
      'ICSE'        => kIcseSubjects,
      'IB'          => kIbSubjects,
      'IGCSE'       => kIgcseSubjects,
      _             => kStateBoardSubjects,
    };
    // Map group to grade keys
    final grades = switch (group) {
      'KG – 5th'    => map.keys.where((k) => k.contains('1') || k.contains('2') || k.contains('3') || k.contains('4') || k.contains('5') || k.contains('KG') || k.contains('1–5')).toList(),
      '6th – 8th'   => map.keys.where((k) => k.contains('6') || k.contains('7') || k.contains('8') || k.contains('6–8')).toList(),
      '9th – 10th'  => map.keys.where((k) => k.contains('9') || k.contains('10') || k.contains('9–10')).toList(),
      '11th – 12th' => map.keys.where((k) => k.contains('11') || k.contains('12') || k.contains('11–12') || k.contains('AP')).toList(),
      _             => <String>[],
    };
    final Set<String> all = {};
    for (final g in grades) { all.addAll(map[g] ?? []); }
    return all.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final subjects = _subjects;
    if (subjects.isEmpty) return const SizedBox.shrink();
    return _SectionCard(
      cs: cs, tt: tt,
      title: '$board · $group',
      subtitle: 'Select subjects you teach',
      child: _ChipWrap(
        options: subjects,
        selected: selected,
        cs: cs, tt: tt,
        onTap: (v) {
          final next = Set<String>.from(selected);
          next.contains(v) ? next.remove(v) : next.add(v);
          onChanged(next);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.cs, required this.tt, required this.title, required this.subtitle, required this.child});
  final ColorScheme cs;
  final TextTheme tt;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(24)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: tt.titleSmall?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w700)),
      const SizedBox(height: 2),
      Text(subtitle, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
      const SizedBox(height: 12),
      child,
    ]),
  );
}

class _ChipWrap extends StatefulWidget {
  const _ChipWrap({required this.options, required this.selected, required this.cs, required this.tt, required this.onTap});
  final List<String> options;
  final Set<String> selected;
  final ColorScheme cs;
  final TextTheme tt;
  final void Function(String) onTap;

  @override
  State<_ChipWrap> createState() => _ChipWrapState();
}

class _ChipWrapState extends State<_ChipWrap> {
  final _ctrl = TextEditingController();
  bool _showOtherInput = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submitOther() async {
    final v = _ctrl.text.trim();
    if (v.isNotEmpty) {
      if (!kAllKnownOptions.contains(v.toLowerCase())) {
        // Show confirmation dialog
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Confirm Spelling', style: widget.tt.titleLarge?.copyWith(color: widget.cs.onSurface)),
            content: Text('"$v" is not in our database. Are you sure this is spelled correctly?', style: widget.tt.bodyMedium?.copyWith(color: widget.cs.onSurfaceVariant)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Edit')),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: widget.cs.tertiary, foregroundColor: widget.cs.onTertiary),
                child: const Text('Yes, add it'),
              ),
            ],
          ),
        );
        if (confirm != true) return;
      }

      widget.onTap(v);
      _ctrl.clear();
      setState(() => _showOtherInput = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.options.map((o) {
            final sel = widget.selected.contains(o);
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                if (o == 'Others') {
                  setState(() => _showOtherInput = !_showOtherInput);
                } else {
                  widget.onTap(o);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? widget.cs.tertiaryContainer : widget.cs.surface,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: sel ? widget.cs.tertiary : Colors.transparent, width: 2),
                ),
                child: Text(o, style: widget.tt.bodySmall?.copyWith(
                  color: sel ? widget.cs.onTertiaryContainer : widget.cs.onSurface,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                )),
              ),
            );
          }).toList(),
        ),
        if (_showOtherInput) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            autofocus: true,
            autocorrect: true,
            enableSuggestions: true,
            spellCheckConfiguration: const SpellCheckConfiguration(),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submitOther(),
            style: widget.tt.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Enter other...',
              hintStyle: widget.tt.bodySmall?.copyWith(color: widget.cs.onSurfaceVariant),
              filled: true,
              fillColor: widget.cs.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              suffixIcon: IconButton(
                icon: Icon(Icons.check_circle_rounded, color: widget.cs.tertiary),
                onPressed: _submitOther,
              ),
            ),
          ),
        ],
        // Show already added "Others" as removable chips if they are not in the standard options
        if (widget.selected.any((s) => !widget.options.contains(s))) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selected.where((s) => !widget.options.contains(s)).map((o) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.cs.tertiaryContainer,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: widget.cs.tertiary, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(o, style: widget.tt.bodySmall?.copyWith(color: widget.cs.onTertiaryContainer, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => widget.onTap(o),
                    child: Icon(Icons.close_rounded, size: 14, color: widget.cs.onTertiaryContainer),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }
}
