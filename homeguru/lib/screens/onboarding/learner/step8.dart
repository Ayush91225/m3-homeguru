import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LearnerStep8Body extends StatefulWidget {
  const LearnerStep8Body({
    super.key,
    required this.categoryIndex,
    required this.onNext,
  });

  final int categoryIndex;
  final void Function(Map<String, dynamic> data) onNext;

  @override
  State<LearnerStep8Body> createState() => _LearnerStep8BodyState();
}

class _LearnerStep8BodyState extends State<LearnerStep8Body> {
  @override
  Widget build(BuildContext context) {
    switch (widget.categoryIndex) {
      case 0: return _BoardCard(onNext: widget.onNext);
      case 1: return _AspirantCard(onNext: widget.onNext);
      case 2: return _CollegeCard(onNext: widget.onNext);
      default: return _SkipCard(onNext: widget.onNext);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Board Card — Student
// ─────────────────────────────────────────────────────────────────────────────

class _BoardCard extends StatefulWidget {
  const _BoardCard({required this.onNext});
  final void Function(Map<String, dynamic>) onNext;

  @override
  State<_BoardCard> createState() => _BoardCardState();
}

class _BoardCardState extends State<_BoardCard> {
  String? _board;
  String? _classYear;
  final _schoolCtrl = TextEditingController();

  static const _boards = ['CBSE', 'ICSE', 'State Board', 'IB', 'IGCSE'];

  static const _cbseClasses = ['Class 1','Class 2','Class 3','Class 4','Class 5','Class 6','Class 7','Class 8','Class 9','Class 10','Class 11','Class 12'];
  static const _ibYears = ['Year 1','Year 2','Year 3','Year 4','Year 5','Year 6','Year 7','Year 8','Year 9','Year 10','Year 11','Year 12'];

  List<String> get _classes => _board == 'IB' || _board == 'IGCSE' ? _ibYears : _cbseClasses;

  @override
  void dispose() { _schoolCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= 600 ? w * 0.2 : 20.0;

    return Column(children: [
      Expanded(child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _Card(cs: cs, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _CardTitle('Board', cs, tt),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: _boards.map((b) {
              final sel = _board == b;
              return GestureDetector(
                onTap: () { HapticFeedback.selectionClick(); setState(() { _board = b; _classYear = null; }); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? cs.primaryContainer : cs.surface,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: sel ? cs.primary : Colors.transparent, width: 2),
                  ),
                  child: Text(b, style: tt.bodyMedium?.copyWith(color: sel ? cs.onPrimaryContainer : cs.onSurface, fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                ),
              );
            }).toList()),
          ])),

          if (_board != null) ...[
            const SizedBox(height: 16),
            _Card(cs: cs, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _CardTitle(_board == 'IB' || _board == 'IGCSE' ? 'Year' : 'Class', cs, tt),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: _classes.map((c) {
                final sel = _classYear == c;
                return GestureDetector(
                  onTap: () { HapticFeedback.selectionClick(); setState(() => _classYear = c); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? cs.primaryContainer : cs.surface,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: sel ? cs.primary : Colors.transparent, width: 2),
                    ),
                    child: Text(c, style: tt.bodySmall?.copyWith(color: sel ? cs.onPrimaryContainer : cs.onSurface, fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                  ),
                );
              }).toList()),
            ])),
          ],

          const SizedBox(height: 16),
          _Card(cs: cs, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _CardTitle('School name', cs, tt),
            const SizedBox(height: 4),
            Text('Optional', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _schoolCtrl,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'School name', prefixIcon: Icon(Icons.school_outlined)),
            ),
          ])),
        ]),
      )),
      Padding(
        padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
        child: FilledButton(
          onPressed: _board == null || _classYear == null ? null : () {
            HapticFeedback.mediumImpact();
            widget.onNext({'board': _board, 'classYear': _classYear, 'school': _schoolCtrl.text.trim()});
          },
          child: const Text('Finish'),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Aspirant Card
// ─────────────────────────────────────────────────────────────────────────────

class _AspirantCard extends StatefulWidget {
  const _AspirantCard({required this.onNext});
  final void Function(Map<String, dynamic>) onNext;

  @override
  State<_AspirantCard> createState() => _AspirantCardState();
}

class _AspirantCardState extends State<_AspirantCard> {
  String? _field;
  String? _exam;
  final _customExamCtrl = TextEditingController();

  static const _examsByField = <String, List<String>>{
    'Engineering': ['JEE Main', 'JEE Advanced', 'BITSAT', 'VITEEE', 'MHT-CET', 'Others'],
    'Medical': ['NEET UG', 'NEET PG', 'AIIMS', 'JIPMER', 'Others'],
    'Govt Jobs': ['UPSC CSE', 'SSC CGL', 'SSC CHSL', 'IBPS PO', 'IBPS Clerk', 'SBI PO', 'RRB NTPC', 'State PSC', 'Others'],
    'Law & Commerce': ['CLAT', 'AILET', 'CA Foundation', 'CA Intermediate', 'CA Final', 'CS Foundation', 'Others'],
    'MBA': ['CAT', 'XAT', 'GMAT', 'MAT', 'SNAP', 'NMAT', 'Others'],
    'Study Abroad': ['IELTS', 'TOEFL', 'GRE', 'GMAT', 'SAT', 'ACT', 'DUOLINGO', 'Others'],
    'Olympiads': ['IMO', 'NSO', 'IEO', 'NTSE', 'KVPY', 'RMO', 'Others'],
  };

  List<String> get _fields => _examsByField.keys.toList();
  List<String> get _exams => _field != null ? (_examsByField[_field] ?? []) : [];

  @override
  void dispose() { _customExamCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= 600 ? w * 0.2 : 20.0;

    return Column(children: [
      Expanded(child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _Card(cs: cs, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _CardTitle('Field / Category', cs, tt),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: _fields.map((f) {
              final sel = _field == f;
              return GestureDetector(
                onTap: () { HapticFeedback.selectionClick(); setState(() { _field = f; _exam = null; }); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? cs.primaryContainer : cs.surface,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: sel ? cs.primary : Colors.transparent, width: 2),
                  ),
                  child: Text(f, style: tt.bodyMedium?.copyWith(color: sel ? cs.onPrimaryContainer : cs.onSurface, fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                ),
              );
            }).toList()),
          ])),

          if (_field != null) ...[
            const SizedBox(height: 16),
            _Card(cs: cs, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _CardTitle('Exam', cs, tt),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: _exams.map((e) {
                final sel = _exam == e;
                return GestureDetector(
                  onTap: () { HapticFeedback.selectionClick(); setState(() => _exam = e); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? cs.primaryContainer : cs.surface,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: sel ? cs.primary : Colors.transparent, width: 2),
                    ),
                    child: Text(e, style: tt.bodyMedium?.copyWith(color: sel ? cs.onPrimaryContainer : cs.onSurface, fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                  ),
                );
              }).toList()),
            ])),
          ],

          if (_exam == 'Others') ...[
            const SizedBox(height: 16),
            _Card(cs: cs, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _CardTitle('Custom exam', cs, tt),
              const SizedBox(height: 12),
              TextFormField(
                controller: _customExamCtrl,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Enter exam name', prefixIcon: Icon(Icons.edit_outlined)),
              ),
            ])),
          ],
        ]),
      )),
      Padding(
        padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
        child: FilledButton(
          onPressed: _field == null || _exam == null ? null : () {
            HapticFeedback.mediumImpact();
            widget.onNext({'field': _field, 'exam': _exam == 'Others' ? _customExamCtrl.text.trim() : _exam});
          },
          child: const Text('Finish'),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// College Card
// ─────────────────────────────────────────────────────────────────────────────

class _CollegeCard extends StatefulWidget {
  const _CollegeCard({required this.onNext});
  final void Function(Map<String, dynamic>) onNext;

  @override
  State<_CollegeCard> createState() => _CollegeCardState();
}

class _CollegeCardState extends State<_CollegeCard> {
  String? _field;
  String? _course;
  String? _branch;
  String? _year;
  final _customCourseCtrl = TextEditingController();
  final _customBranchCtrl = TextEditingController();

  static const _coursesByField = <String, List<String>>{
    'Engineering & Tech': ['B.Tech', 'B.E.', 'M.Tech', 'M.E.', 'Diploma Engineering', 'Others'],
    'Computer Applications': ['BCA', 'MCA', 'B.Sc CS', 'M.Sc CS', 'Others'],
    'Commerce & Business': ['B.Com', 'M.Com', 'BBA', 'MBA', 'BMS', 'Others'],
    'Law': ['BA LLB', 'BBA LLB', 'LLB', 'LLM', 'Others'],
    'Science': ['B.Sc', 'M.Sc', 'B.Sc Hons', 'Others'],
    'Humanities & Arts': ['BA', 'MA', 'BA Hons', 'Others'],
    'Education': ['B.Ed', 'M.Ed', 'D.El.Ed', 'Others'],
    'Medical & Healthcare': ['MBBS', 'BDS', 'BAMS', 'BHMS', 'B.Pharm', 'M.Pharm', 'B.Sc Nursing', 'Others'],
    'Design & Creative': ['B.Des', 'M.Des', 'BFA', 'MFA', 'Others'],
    'Professional Courses': ['CA', 'CS', 'CMA', 'CFA', 'FRM', 'Others'],
  };

  static const _branchesByCourse = <String, List<String>>{
    'B.Tech': ['Computer Science', 'Information Technology', 'Electronics & Communication', 'Electrical', 'Mechanical', 'Civil', 'Chemical', 'Aerospace', 'Others'],
    'B.E.': ['Computer Science', 'Electronics', 'Mechanical', 'Civil', 'Electrical', 'Others'],
    'M.Tech': ['Computer Science', 'VLSI', 'Power Systems', 'Structural', 'Others'],
    'B.Sc': ['Physics', 'Chemistry', 'Mathematics', 'Biology', 'Computer Science', 'Statistics', 'Others'],
    'BA': ['English', 'History', 'Political Science', 'Economics', 'Psychology', 'Sociology', 'Philosophy', 'Others'],
    'MA': ['English', 'History', 'Political Science', 'Economics', 'Psychology', 'Sociology', 'Others'],
  };

  static const _years = ['1st Year', '2nd Year', '3rd Year', '4th Year', '5th Year'];
  List<String> get _fields => _coursesByField.keys.toList();
  List<String> get _courses => _field != null ? (_coursesByField[_field] ?? []) : [];
  List<String> get _branches => _course != null ? (_branchesByCourse[_course] ?? ['Others']) : [];

  @override
  void dispose() { _customCourseCtrl.dispose(); _customBranchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= 600 ? w * 0.2 : 20.0;

    return Column(children: [
      Expanded(child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

          _Card(cs: cs, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _CardTitle('Field', cs, tt),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: _fields.map((f) {
              final sel = _field == f;
              return GestureDetector(
                onTap: () { HapticFeedback.selectionClick(); setState(() { _field = f; _course = null; _branch = null; }); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: sel ? cs.primaryContainer : cs.surface,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: sel ? cs.primary : Colors.transparent, width: 2),
                  ),
                  child: Text(f, style: tt.bodySmall?.copyWith(color: sel ? cs.onPrimaryContainer : cs.onSurface, fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                ),
              );
            }).toList()),
          ])),

          if (_field != null) ...[
            const SizedBox(height: 16),
            _Card(cs: cs, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _CardTitle('Course', cs, tt),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: _courses.map((c) {
                final sel = _course == c;
                return GestureDetector(
                  onTap: () { HapticFeedback.selectionClick(); setState(() { _course = c; _branch = null; }); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: sel ? cs.primaryContainer : cs.surface,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: sel ? cs.primary : Colors.transparent, width: 2),
                    ),
                    child: Text(c, style: tt.bodySmall?.copyWith(color: sel ? cs.onPrimaryContainer : cs.onSurface, fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                  ),
                );
              }).toList()),
              if (_course == 'Others') ...[
                const SizedBox(height: 12),
                TextFormField(controller: _customCourseCtrl, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Enter course name')),
              ],
            ])),
          ],

          if (_course != null && _course != 'Others' && _branches.isNotEmpty) ...[
            const SizedBox(height: 16),
            _Card(cs: cs, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _CardTitle('Branch / Specialization', cs, tt),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: _branches.map((b) {
                final sel = _branch == b;
                return GestureDetector(
                  onTap: () { HapticFeedback.selectionClick(); setState(() => _branch = b); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: sel ? cs.primaryContainer : cs.surface,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: sel ? cs.primary : Colors.transparent, width: 2),
                    ),
                    child: Text(b, style: tt.bodySmall?.copyWith(color: sel ? cs.onPrimaryContainer : cs.onSurface, fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                  ),
                );
              }).toList()),
              if (_branch == 'Others') ...[
                const SizedBox(height: 12),
                TextFormField(controller: _customBranchCtrl, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Enter branch name')),
              ],
            ])),
          ],

          const SizedBox(height: 16),
          _Card(cs: cs, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _CardTitle('Year', cs, tt),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: _years.map((y) {
              final sel = _year == y;
              return GestureDetector(
                onTap: () { HapticFeedback.selectionClick(); setState(() => _year = y); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: sel ? cs.primaryContainer : cs.surface,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: sel ? cs.primary : Colors.transparent, width: 2),
                  ),
                  child: Text(y, style: tt.bodySmall?.copyWith(color: sel ? cs.onPrimaryContainer : cs.onSurface, fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                ),
              );
            }).toList()),
          ])),
        ]),
      )),
      Padding(
        padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
        child: FilledButton(
          onPressed: _field == null || _course == null || _year == null ? null : () {
            HapticFeedback.mediumImpact();
            widget.onNext({
              'field': _field,
              'course': _course == 'Others' ? _customCourseCtrl.text.trim() : _course,
              'branch': _branch == 'Others' ? _customBranchCtrl.text.trim() : _branch,
              'year': _year,
            });
          },
          child: const Text('Finish'),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skip card — Working Professional, Homemaker, Sr. Citizen
// ─────────────────────────────────────────────────────────────────────────────

class _SkipCard extends StatelessWidget {
  const _SkipCard({required this.onNext});
  final void Function(Map<String, dynamic>) onNext;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= 600 ? w * 0.2 : 24.0;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Expanded(child: Padding(
        padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.check_circle_outline_rounded, size: 64, color: cs.primary),
          const SizedBox(height: 24),
          Text("You're all set!", style: tt.headlineMedium?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text("Your profile is ready. Let's find you the perfect tutor.", textAlign: TextAlign.center, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.5)),
        ]),
      )),
      Padding(
        padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
        child: FilledButton(
          onPressed: () { HapticFeedback.mediumImpact(); onNext({}); },
          child: const Text('Finish'),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared local widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.cs, required this.child});
  final ColorScheme cs;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(24)),
    child: child,
  );
}

class _CardTitle extends StatelessWidget {
  const _CardTitle(this.label, this.cs, this.tt);
  final String label;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) => Text(label, style: tt.titleSmall?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w700));
}
