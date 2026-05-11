import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../screens/onboarding/tutor/step4_data.dart';

/// Full subject selection sheet — same categories as onboarding.
/// Returns Map with all selected data to merge into tutor profile.
class AddSubjectSheet extends StatefulWidget {
  const AddSubjectSheet({super.key, this.existingSubjects});
  final Map<String, dynamic>? existingSubjects;

  @override
  State<AddSubjectSheet> createState() => _AddSubjectSheetState();
}

class _AddSubjectSheetState extends State<AddSubjectSheet> {
  // Teaching level selected (one at a time for this flow)
  String? _level;

  // Schooling
  String? _board;
  String? _classGroup;
  final Set<String> _schoolSubjects = {};

  // Competitive exams
  String? _examCategory;
  final Set<String> _exams = {};

  // Study abroad
  final Set<String> _studyAbroad = {};

  // Non-academic
  String? _nonAcademicType;
  final Set<String> _nonAcademicItems = {};
  // Music sub
  String? _musicType;
  final Set<String> _musicItems = {};

  // Languages
  final Set<String> _languages = {};

  bool get _canAdd {
    switch (_level) {
      case 'Schooling':
        return _board != null && _classGroup != null && _schoolSubjects.isNotEmpty;
      case 'Competitive Exams':
      case 'Olympiad':
        return _examCategory != null && _exams.isNotEmpty;
      case 'Study Abroad':
        return _studyAbroad.isNotEmpty;
      case 'Non-Academic':
        if (_nonAcademicType == 'Music') return _musicType != null && _musicItems.isNotEmpty;
        if (_nonAcademicType == 'Dance' || _nonAcademicType == 'Coding & Computers') return _nonAcademicItems.isNotEmpty;
        return _nonAcademicType != null;
      case 'Language Learning':
        return _languages.isNotEmpty;
      default:
        return false;
    }
  }

  List<String> get _availableSchoolSubjects {
    if (_board == null || _classGroup == null) return [];
    final map = switch (_board!) {
      'CBSE' => kCbseSubjects,
      'ICSE' => kIcseSubjects,
      'IB' => kIbSubjects,
      'IGCSE' => kIgcseSubjects,
      _ => kStateBoardSubjects,
    };
    final grades = switch (_classGroup!) {
      'KG – 5th' => map.keys.where((k) => k.contains('1') || k.contains('2') || k.contains('3') || k.contains('4') || k.contains('5') || k.contains('KG') || k.contains('1–5')).toList(),
      '6th – 8th' => map.keys.where((k) => k.contains('6') || k.contains('7') || k.contains('8') || k.contains('6–8')).toList(),
      '9th – 10th' => map.keys.where((k) => k.contains('9') || k.contains('10') || k.contains('9–10')).toList(),
      '11th – 12th' => map.keys.where((k) => k.contains('11') || k.contains('12') || k.contains('11–12') || k.contains('AP')).toList(),
      _ => <String>[],
    };
    final Set<String> all = {};
    for (final g in grades) {
      all.addAll(map[g] ?? []);
    }
    return all.toList()..sort();
  }

  void _done() {
    if (!_canAdd) return;
    final result = <String, dynamic>{'level': _level};

    switch (_level) {
      case 'Schooling':
        result['board'] = _board;
        result['grade'] = _classGroup;
        result['subjects'] = _schoolSubjects.toList();
        break;
      case 'Competitive Exams':
      case 'Olympiad':
        result['category'] = _examCategory;
        result['subjects'] = _exams.toList();
        break;
      case 'Study Abroad':
        result['subjects'] = _studyAbroad.toList();
        break;
      case 'Non-Academic':
        result['type'] = _nonAcademicType;
        if (_nonAcademicType == 'Music') {
          result['musicType'] = _musicType;
          result['subjects'] = _musicItems.toList();
        } else if (_nonAcademicType == 'Dance') {
          result['subjects'] = _nonAcademicItems.toList();
        } else if (_nonAcademicType == 'Coding & Computers') {
          result['subjects'] = _nonAcademicItems.toList();
        } else {
          result['subjects'] = [_nonAcademicType];
        }
        break;
      case 'Language Learning':
        result['subjects'] = _languages.toList();
        break;
    }

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2))),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Text('Add Subjects', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton(onPressed: Navigator.of(ctx).pop, child: const Text('Cancel')),
            ]),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(20),
              children: [
                // Level selection
                _label('Category', tt),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: kTeachingLevels.map((l) => _chip(l, _level == l, cs, tt, () {
                    setState(() { _level = l; _resetSub(); });
                  })).toList(),
                ),

                if (_level != null) ...[
                  const SizedBox(height: 24),
                  ..._buildLevelContent(cs, tt),
                ],
              ],
            ),
          ),
          // Add button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: FilledButton(
              onPressed: _canAdd ? _done : null,
              style: FilledButton.styleFrom(
                backgroundColor: cs.tertiary,
                foregroundColor: cs.onTertiary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add Selected'),
            ),
          ),
        ]),
      ),
    );
  }

  List<Widget> _buildLevelContent(ColorScheme cs, TextTheme tt) {
    switch (_level) {
      case 'Schooling':
        return _buildSchooling(cs, tt);
      case 'Competitive Exams':
      case 'Olympiad':
        return _buildCompetitive(cs, tt);
      case 'Study Abroad':
        return _buildStudyAbroad(cs, tt);
      case 'Non-Academic':
        return _buildNonAcademic(cs, tt);
      case 'Language Learning':
        return _buildLanguages(cs, tt);
      default:
        return [];
    }
  }

  List<Widget> _buildSchooling(ColorScheme cs, TextTheme tt) {
    return [
      _label('Board', tt),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: kBoards.where((b) => b != 'Others').map((b) => _chip(b, _board == b, cs, tt, () {
          setState(() { _board = b; _classGroup = null; _schoolSubjects.clear(); });
        })).toList(),
      ),
      if (_board != null) ...[
        const SizedBox(height: 20),
        _label('Grade Group', tt),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: kClassGroups.where((g) => g != 'Others').map((g) => _chip(g, _classGroup == g, cs, tt, () {
            setState(() { _classGroup = g; _schoolSubjects.clear(); });
          })).toList(),
        ),
      ],
      if (_classGroup != null) ...[
        const SizedBox(height: 20),
        _label('Subjects', tt),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _availableSchoolSubjects.map((s) => _chip(s, _schoolSubjects.contains(s), cs, tt, () {
            HapticFeedback.selectionClick();
            setState(() => _schoolSubjects.contains(s) ? _schoolSubjects.remove(s) : _schoolSubjects.add(s));
          })).toList(),
        ),
      ],
    ];
  }

  List<Widget> _buildCompetitive(ColorScheme cs, TextTheme tt) {
    return [
      _label('Exam Category', tt),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: kCompetitiveExams.keys.map((c) => _chip(c, _examCategory == c, cs, tt, () {
          setState(() { _examCategory = c; _exams.clear(); });
        })).toList(),
      ),
      if (_examCategory != null) ...[
        const SizedBox(height: 20),
        _label('Exams', tt),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: (kCompetitiveExams[_examCategory] ?? []).where((e) => e != 'Others').map((e) => _chip(e, _exams.contains(e), cs, tt, () {
            HapticFeedback.selectionClick();
            setState(() => _exams.contains(e) ? _exams.remove(e) : _exams.add(e));
          })).toList(),
        ),
      ],
    ];
  }

  List<Widget> _buildStudyAbroad(ColorScheme cs, TextTheme tt) {
    return [
      _label('Exams', tt),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: kStudyAbroadExams.where((e) => e != 'Others').map((e) => _chip(e, _studyAbroad.contains(e), cs, tt, () {
          HapticFeedback.selectionClick();
          setState(() => _studyAbroad.contains(e) ? _studyAbroad.remove(e) : _studyAbroad.add(e));
        })).toList(),
      ),
    ];
  }

  List<Widget> _buildNonAcademic(ColorScheme cs, TextTheme tt) {
    return [
      _label('Activity', tt),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: kNonAcademicActivities.where((a) => a != 'Others').map((a) => _chip(a, _nonAcademicType == a, cs, tt, () {
          setState(() { _nonAcademicType = a; _nonAcademicItems.clear(); _musicType = null; _musicItems.clear(); });
        })).toList(),
      ),
      if (_nonAcademicType == 'Music') ...[
        const SizedBox(height: 20),
        _label('Music Type', tt),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: kMusicTypes.keys.map((t) => _chip(t, _musicType == t, cs, tt, () {
            setState(() { _musicType = t; _musicItems.clear(); });
          })).toList(),
        ),
        if (_musicType != null) ...[
          const SizedBox(height: 20),
          _label('Instruments / Styles', tt),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: (kMusicTypes[_musicType] ?? []).where((i) => i != 'Others').map((i) => _chip(i, _musicItems.contains(i), cs, tt, () {
              HapticFeedback.selectionClick();
              setState(() => _musicItems.contains(i) ? _musicItems.remove(i) : _musicItems.add(i));
            })).toList(),
          ),
        ],
      ],
      if (_nonAcademicType == 'Dance') ...[
        const SizedBox(height: 20),
        _label('Dance Styles', tt),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: kDanceStyles.where((d) => d != 'Others').map((d) => _chip(d, _nonAcademicItems.contains(d), cs, tt, () {
            HapticFeedback.selectionClick();
            setState(() => _nonAcademicItems.contains(d) ? _nonAcademicItems.remove(d) : _nonAcademicItems.add(d));
          })).toList(),
        ),
      ],
      if (_nonAcademicType == 'Coding & Computers') ...[
        const SizedBox(height: 20),
        _label('Courses', tt),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: kCodingCourses.where((c) => c != 'Others').map((c) => _chip(c, _nonAcademicItems.contains(c), cs, tt, () {
            HapticFeedback.selectionClick();
            setState(() => _nonAcademicItems.contains(c) ? _nonAcademicItems.remove(c) : _nonAcademicItems.add(c));
          })).toList(),
        ),
      ],
    ];
  }

  List<Widget> _buildLanguages(ColorScheme cs, TextTheme tt) {
    return [
      _label('Foreign Languages', tt),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: kForeignLanguages.where((l) => l != 'Others').map((l) => _chip(l, _languages.contains(l), cs, tt, () {
          HapticFeedback.selectionClick();
          setState(() => _languages.contains(l) ? _languages.remove(l) : _languages.add(l));
        })).toList(),
      ),
      const SizedBox(height: 20),
      _label('Regional Languages', tt),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: kRegionalLanguages.where((l) => l != 'Others').map((l) => _chip(l, _languages.contains(l), cs, tt, () {
          HapticFeedback.selectionClick();
          setState(() => _languages.contains(l) ? _languages.remove(l) : _languages.add(l));
        })).toList(),
      ),
    ];
  }

  void _resetSub() {
    _board = null;
    _classGroup = null;
    _schoolSubjects.clear();
    _examCategory = null;
    _exams.clear();
    _studyAbroad.clear();
    _nonAcademicType = null;
    _nonAcademicItems.clear();
    _musicType = null;
    _musicItems.clear();
    _languages.clear();
  }

  Widget _label(String text, TextTheme tt) => Text(text, style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600));

  Widget _chip(String label, bool selected, ColorScheme cs, TextTheme tt, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.tertiaryContainer : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: selected ? cs.tertiary : Colors.transparent, width: 1.5),
        ),
        child: Text(label, style: tt.bodySmall?.copyWith(
          color: selected ? cs.onTertiaryContainer : cs.onSurface,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        )),
      ),
    );
  }
}
