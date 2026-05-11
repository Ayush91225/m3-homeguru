import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/tutor_profile_service.dart';
import '../../../../widgets/dashboard/tutor/profile/add_subject_sheet.dart';

class TutorProfileEditScreen extends StatefulWidget {
  const TutorProfileEditScreen({super.key});

  @override
  State<TutorProfileEditScreen> createState() => _TutorProfileEditScreenState();
}

class _TutorProfileEditScreenState extends State<TutorProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;
  bool _saving = false;


  final _youtubeCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();



  // Experience: LinkedIn-style entries
  List<Map<String, String>> _experience = [];

  // Education: LinkedIn-style entries
  List<Map<String, String>> _education = [];

  // Rates: list of {subject, inr, international}
  List<Map<String, dynamic>> _rates = [];

  // Availability: day -> list of {start, end}
  Map<String, List<Map<String, String>>> _availability = {
    'monday': [],
    'tuesday': [],
    'wednesday': [],
    'thursday': [],
    'friday': [],
    'saturday': [],
    'sunday': [],
  };

  // Subjects JSON (same structure as onboarding)
  Map<String, dynamic>? _subjectsData;

  String? _tutorId;
  List<String> _subjects = [];
  Map<String, dynamic>? _fullData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _youtubeCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _tutorId = prefs.getString('userId');
    if (_tutorId == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final result = await TutorProfileService.getTutorProfile(_tutorId!);
    if (result['success'] == true && mounted) {
      final data = result['data'] as Map<String, dynamic>;
      _fullData = data;
      _youtubeCtrl.text = data['youtubeVideoLink'] ?? '';

      // Bio
      final profile = data['profile'] as Map<String, dynamic>?;
      _bioCtrl.text = profile?['bio'] ?? '';

      // Subjects data (full JSON)
      _subjectsData = data['subjects'] as Map<String, dynamic>?;
      if (_subjectsData != null) {
        _subjects = _extractSubjectNames(_subjectsData!);
      }

      // Experience (LinkedIn-style list)
      if (data['experience'] != null) {
        if (data['experience'] is List) {
          _experience = (data['experience'] as List)
              .map((e) => Map<String, String>.from(
                  (e as Map).map((k, v) => MapEntry(k.toString(), v.toString()))))
              .toList();
        } else if (data['experience'] is String) {
          _experience = [{'title': 'Teaching', 'org': '', 'period': data['experience']}];
        }
      }

      // Education
      if (data['education'] != null && data['education'] is List) {
        _education = (data['education'] as List)
            .map((e) => Map<String, String>.from(
                (e as Map).map((k, v) => MapEntry(k.toString(), v.toString()))))
            .toList();
      }

      // Rates
      if (data['rates'] != null) {
        _rates = (data['rates'] as List).map((r) => Map<String, dynamic>.from(r)).toList();
      } else {
        _rates = _subjects.map((s) => {'subject': s, 'inr': 0, 'international': 0}).toList();
      }

      // Availability
      if (data['availability'] != null) {
        final avail = data['availability'] as Map<String, dynamic>;
        for (final day in _availability.keys) {
          if (avail[day] != null) {
            _availability[day] = (avail[day] as List)
                .map((slot) => Map<String, String>.from(slot))
                .toList();
          }
        }
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  List<String> _extractSubjectNames(Map<String, dynamic> subjectsData) {
    final names = <String>{};
    final schooling = subjectsData['schooling'];
    if (schooling != null && schooling['subjectsByBoardAndGrade'] != null) {
      final byBoard = schooling['subjectsByBoardAndGrade'] as Map<String, dynamic>;
      for (final board in byBoard.values) {
        if (board is Map) {
          for (final subjects in board.values) {
            if (subjects is List) names.addAll(subjects.cast<String>());
          }
        }
      }
    }
    return names.toList();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final updates = <String, dynamic>{
      'youtubeVideoLink': _youtubeCtrl.text.trim(),
      'experience': _experience,
      'education': _education,
      'rates': _rates,
      'availability': _availability,
      'profile': {
        ...(_fullData?['profile'] as Map<String, dynamic>? ?? {}),
        'bio': _bioCtrl.text.trim(),
      },
    };

    final result = await TutorProfileService.updateProfile(_tutorId!, updates);

    if (mounted) {
      setState(() => _saving = false);
      if (result['success'] == true) {
        final isComplete = result['isComplete'] == true;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isComplete
              ? 'Profile complete! You are now listed.'
              : 'Saved. Complete all fields to go live.'),
          backgroundColor: isComplete ? Colors.green : null,
        ));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Save failed')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(backgroundColor: cs.tertiary, foregroundColor: cs.onTertiary),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(foregroundColor: cs.tertiary, side: BorderSide(color: cs.tertiary)),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: cs.tertiary),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          actions: [
            TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('Save', style: TextStyle(color: cs.tertiary)),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Non-editable user info
              _buildUserInfoHeader(cs, tt),
              const SizedBox(height: 24),

              // Bio
            _SectionHeader(title: 'Bio', icon: Icons.info_outline_rounded),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bioCtrl,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Tell students about yourself...'),
            ),

            const SizedBox(height: 24),

            // Experience (LinkedIn-style)
            _SectionHeader(title: 'Experience', icon: Icons.work_rounded),
            const SizedBox(height: 8),
            ..._buildExperienceSection(cs, tt),

            const SizedBox(height: 24),

            // Education (LinkedIn-style)
            _SectionHeader(title: 'Education', icon: Icons.school_rounded),
            const SizedBox(height: 8),
            ..._buildEducationSection(cs, tt),

            const SizedBox(height: 24),

            // YouTube Video Link
            _SectionHeader(title: 'Introduction Video', icon: Icons.play_circle_rounded),
            const SizedBox(height: 8),
            TextFormField(
              controller: _youtubeCtrl,
              decoration: const InputDecoration(
                hintText: 'YouTube video link',
                prefixIcon: Icon(Icons.videocam_rounded),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),

            const SizedBox(height: 24),

            // Rates
            _SectionHeader(title: 'Subject-wise Rates (per hour)', icon: Icons.currency_rupee_rounded),
            const SizedBox(height: 12),
            ..._buildRatesSection(cs, tt),

            const SizedBox(height: 16),

            // Add new subject to profile
            OutlinedButton.icon(
              onPressed: _showAddSubjectSheet,
              icon: const Icon(Icons.library_add_outlined, size: 18),
              label: const Text('Add Subject'),
            ),

            const SizedBox(height: 24),

            // Availability
            _SectionHeader(title: 'Availability', icon: Icons.calendar_month_rounded),
            const SizedBox(height: 12),
            ..._buildAvailabilitySection(cs, tt),

            const SizedBox(height: 32),

            // Save Button
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                  : const Text('Save & Go Live', style: TextStyle(fontSize: 16)),
            ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoHeader(ColorScheme cs, TextTheme tt) {
    final name = '${_fullData?['firstName'] ?? ''} ${_fullData?['lastName'] ?? ''}'.trim();
    final email = _fullData?['email'] ?? '';
    final phone = _fullData?['phone'] ?? _fullData?['phoneNumber'] ?? '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.tertiary.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.person_rounded, size: 18, color: cs.tertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(name.isNotEmpty ? name : 'Name not set',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: name.isNotEmpty ? cs.onSurface : cs.onSurfaceVariant)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
            child: Text('Not editable', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 9)),
          ),
        ]),
        const SizedBox(height: 10),
        if (email.isNotEmpty)
          Row(children: [
            Icon(Icons.email_outlined, size: 16, color: cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(email, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ]),
        if (phone.isNotEmpty) ...[  
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.phone_outlined, size: 16, color: cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(phone, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ]),
        ],
      ]),
    );
  }

  List<Widget> _buildExperienceSection(ColorScheme cs, TextTheme tt) {
    final widgets = <Widget>[];
    for (int i = 0; i < _experience.length; i++) {
      widgets.add(Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: cs.tertiaryContainer, borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.work_outline, size: 18, color: cs.tertiary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_experience[i]['title'] ?? '', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  if ((_experience[i]['org'] ?? '').isNotEmpty)
                    Text(_experience[i]['org']!, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  if ((_experience[i]['period'] ?? '').isNotEmpty)
                    Text(_experience[i]['period']!, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                ]),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: cs.error, size: 20),
                onPressed: () => setState(() => _experience.removeAt(i)),
              ),
            ]),
          ],
        ),
      ));
    }
    widgets.add(OutlinedButton.icon(
      onPressed: _showAddExperienceDialog,
      icon: const Icon(Icons.add, size: 18),
      label: const Text('Add Experience'),
    ));
    return widgets;
  }

  void _showAddExperienceDialog() {
    final titleCtrl = TextEditingController();
    final orgCtrl = TextEditingController();
    String? startMonth, startYear, endMonth, endYear;
    bool present = false;
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final years = List.generate(30, (i) => '${DateTime.now().year - i}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Add Experience', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title (e.g. Math Teacher)'), autofocus: true),
            const SizedBox(height: 12),
            TextField(controller: orgCtrl, decoration: const InputDecoration(labelText: 'Organization')),
            const SizedBox(height: 16),
            Text('Start Date', style: Theme.of(ctx).textTheme.labelMedium),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(value: startMonth, decoration: const InputDecoration(labelText: 'Month', isDense: true), items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(), onChanged: (v) => setSheetState(() => startMonth = v))),
              const SizedBox(width: 12),
              Expanded(child: DropdownButtonFormField<String>(value: startYear, decoration: const InputDecoration(labelText: 'Year', isDense: true), items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(), onChanged: (v) => setSheetState(() => startYear = v))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Text('End Date', style: Theme.of(ctx).textTheme.labelMedium),
              const Spacer(),
              Text('Present', style: Theme.of(ctx).textTheme.labelSmall),
              Switch(value: present, onChanged: (v) => setSheetState(() => present = v)),
            ]),
            if (!present) ...[  
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: DropdownButtonFormField<String>(value: endMonth, decoration: const InputDecoration(labelText: 'Month', isDense: true), items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(), onChanged: (v) => setSheetState(() => endMonth = v))),
                const SizedBox(width: 12),
                Expanded(child: DropdownButtonFormField<String>(value: endYear, decoration: const InputDecoration(labelText: 'Year', isDense: true), items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(), onChanged: (v) => setSheetState(() => endYear = v))),
              ]),
            ],
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                final start = '${startMonth ?? ''} ${startYear ?? ''}'.trim();
                final end = present ? 'Present' : '${endMonth ?? ''} ${endYear ?? ''}'.trim();
                final period = start.isNotEmpty ? '$start - $end' : '';
                setState(() => _experience.add({'title': titleCtrl.text.trim(), 'org': orgCtrl.text.trim(), 'period': period}));
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            )),
          ]),
        ),
      ),
    );
  }

  List<Widget> _buildEducationSection(ColorScheme cs, TextTheme tt) {
    final widgets = <Widget>[];
    for (int i = 0; i < _education.length; i++) {
      widgets.add(Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: cs.tertiaryContainer, borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.school_outlined, size: 18, color: cs.tertiary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_education[i]['title'] ?? '', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              if ((_education[i]['org'] ?? '').isNotEmpty)
                Text(_education[i]['org']!, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              if ((_education[i]['period'] ?? '').isNotEmpty)
                Text(_education[i]['period']!, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
            ]),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: cs.error, size: 20),
            onPressed: () => setState(() => _education.removeAt(i)),
          ),
        ]),
      ));
    }
    widgets.add(OutlinedButton.icon(
      onPressed: _showAddEducationDialog,
      icon: const Icon(Icons.add, size: 18),
      label: const Text('Add Education'),
    ));
    return widgets;
  }

  void _showAddEducationDialog() {
    final titleCtrl = TextEditingController();
    final orgCtrl = TextEditingController();
    String? startYear, endYear;
    final years = List.generate(30, (i) => '${DateTime.now().year - i}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Add Education', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Degree (e.g. B.Sc Mathematics)'), autofocus: true),
            const SizedBox(height: 12),
            TextField(controller: orgCtrl, decoration: const InputDecoration(labelText: 'Institution')),
            const SizedBox(height: 16),
            Text('Duration', style: Theme.of(ctx).textTheme.labelMedium),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(value: startYear, decoration: const InputDecoration(labelText: 'Start Year', isDense: true), items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(), onChanged: (v) => setSheetState(() => startYear = v))),
              const SizedBox(width: 12),
              Expanded(child: DropdownButtonFormField<String>(value: endYear, decoration: const InputDecoration(labelText: 'End Year', isDense: true), items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(), onChanged: (v) => setSheetState(() => endYear = v))),
            ]),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                final period = (startYear != null || endYear != null) ? '${startYear ?? ''} - ${endYear ?? ''}' : '';
                setState(() => _education.add({'title': titleCtrl.text.trim(), 'org': orgCtrl.text.trim(), 'period': period}));
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            )),
          ]),
        ),
      ),
    );
  }

  List<Widget> _buildRatesSection(ColorScheme cs, TextTheme tt) {
    final widgets = <Widget>[];
    for (int i = 0; i < _rates.length; i++) {
      final r = _rates[i];
      final label = r['board'] != null
          ? '${r['subject']} • ${r['board']} • ${r['grade']}'
          : r['subject'] ?? 'Subject ${i + 1}';
      widgets.add(Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(label, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
            GestureDetector(
              onTap: () => setState(() => _rates.removeAt(i)),
              child: Icon(Icons.close, color: cs.error, size: 18),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextFormField(
              initialValue: r['inr']?.toString() ?? '',
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '₹ INR/hr', isDense: true),
              onChanged: (v) => _rates[i]['inr'] = int.tryParse(v) ?? 0,
            )),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(
              initialValue: r['international']?.toString() ?? '',
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '\$ USD/hr', isDense: true),
              onChanged: (v) => _rates[i]['international'] = int.tryParse(v) ?? 0,
            )),
          ]),
        ]),
      ));
    }

    return widgets;
  }

  void _showAddRateSheet() {
    final byBoard = <String, Map<String, List<String>>>{};
    final schooling = _subjectsData?['schooling'];
    if (schooling != null && schooling['subjectsByBoardAndGrade'] != null) {
      final data = schooling['subjectsByBoardAndGrade'] as Map<String, dynamic>;
      for (final board in data.entries) {
        byBoard[board.key] = {};
        if (board.value is Map) {
          for (final grade in (board.value as Map).entries) {
            if (grade.value is List) {
              byBoard[board.key]![grade.key.toString()] = List<String>.from(grade.value);
            }
          }
        }
      }
    }
    if (byBoard.isEmpty) return;

    String? selectedBoard, selectedGrade, selectedSubject;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final grades = selectedBoard != null ? byBoard[selectedBoard]!.keys.toList() : <String>[];
          final subjects = (selectedBoard != null && selectedGrade != null)
              ? (byBoard[selectedBoard]![selectedGrade] ?? <String>[])
              : <String>[];

          return Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Add Subject Rate', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedBoard,
                decoration: const InputDecoration(labelText: 'Board', isDense: true),
                items: byBoard.keys.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (v) => setSheetState(() { selectedBoard = v; selectedGrade = null; selectedSubject = null; }),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedGrade,
                decoration: const InputDecoration(labelText: 'Grade Group', isDense: true),
                items: grades.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setSheetState(() { selectedGrade = v; selectedSubject = null; }),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedSubject,
                decoration: const InputDecoration(labelText: 'Subject', isDense: true),
                items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setSheetState(() => selectedSubject = v),
              ),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: FilledButton(
                onPressed: (selectedBoard != null && selectedGrade != null && selectedSubject != null) ? () {
                  setState(() => _rates.add({'subject': selectedSubject, 'board': selectedBoard, 'grade': selectedGrade, 'inr': 0, 'international': 0}));
                  Navigator.pop(ctx);
                } : null,
                child: const Text('Add'),
              )),
            ]),
          );
        },
      ),
    );
  }

  List<Widget> _buildAvailabilitySection(ColorScheme cs, TextTheme tt) {
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return [
      for (int i = 0; i < days.length; i++)
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(dayLabels[i], style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 22),
                    onPressed: () => _addSlot(days[i]),
                  ),
                ],
              ),
              if (_availability[days[i]]!.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('No slots', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ),
              for (int j = 0; j < _availability[days[i]]!.length; j++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: cs.tertiary),
                      const SizedBox(width: 8),
                      Text('${_availability[days[i]]![j]['start']} - ${_availability[days[i]]![j]['end']}',
                          style: tt.bodySmall),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _availability[days[i]]!.removeAt(j)),
                        child: Icon(Icons.close, size: 16, color: cs.error),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
    ];
  }

  Future<void> _addSlot(String day) async {
    final start = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 9, minute: 0));
    if (start == null || !mounted) return;
    final end = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 12, minute: 0));
    if (end == null || !mounted) return;

    final startStr = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final endStr = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';

    // Prevent duplicates
    final exists = _availability[day]!.any((s) => s['start'] == startStr && s['end'] == endStr);
    if (exists) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This slot already exists')));
      return;
    }

    setState(() {
      _availability[day]!.add({'start': startStr, 'end': endStr});
    });
  }

  Future<void> _showAddSubjectSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddSubjectSheet(existingSubjects: _subjectsData),
    );
    if (result == null || !mounted) return;

    final level = result['level'] as String;
    final subjects = List<String>.from(result['subjects'] ?? []);

    _subjectsData ??= {};

    // Update teachingLevels
    final levels = Set<String>.from(_subjectsData!['teachingLevels'] ?? [])..add(level);
    _subjectsData!['teachingLevels'] = levels.toList();

    switch (level) {
      case 'Schooling':
        final board = result['board'] as String;
        final grade = result['grade'] as String;
        _subjectsData!['schooling'] ??= {};
        _subjectsData!['schooling']['subjectsByBoardAndGrade'] ??= {};
        _subjectsData!['schooling']['subjectsByBoardAndGrade'][board] ??= {};
        final existing = _subjectsData!['schooling']['subjectsByBoardAndGrade'][board][grade];
        if (existing is List) {
          final merged = Set<String>.from(existing)..addAll(subjects);
          _subjectsData!['schooling']['subjectsByBoardAndGrade'][board][grade] = merged.toList();
        } else {
          _subjectsData!['schooling']['subjectsByBoardAndGrade'][board][grade] = subjects;
        }
        final boards = Set<String>.from(_subjectsData!['schooling']['boards'] ?? [])..add(board);
        _subjectsData!['schooling']['boards'] = boards.toList();
        final groups = Set<String>.from(_subjectsData!['schooling']['classGroups'] ?? [])..add(grade);
        _subjectsData!['schooling']['classGroups'] = groups.toList();
        // Add rate entries
        for (final sub in subjects) {
          if (!_rates.any((r) => r['subject'] == sub && r['board'] == board && r['grade'] == grade)) {
            _rates.add({'subject': sub, 'board': board, 'grade': grade, 'inr': 0, 'international': 0});
          }
        }
        break;

      case 'Competitive Exams':
      case 'Olympiad':
        final category = result['category'] as String;
        _subjectsData!['competitiveExams'] ??= {};
        final existing = Set<String>.from(_subjectsData!['competitiveExams'][category] ?? [])..addAll(subjects);
        _subjectsData!['competitiveExams'][category] = existing.toList();
        for (final sub in subjects) {
          if (!_rates.any((r) => r['subject'] == sub && r['board'] == category)) {
            _rates.add({'subject': sub, 'board': category, 'grade': level, 'inr': 0, 'international': 0});
          }
        }
        break;

      case 'Study Abroad':
        final existing = Set<String>.from(_subjectsData!['studyAbroadExams'] ?? [])..addAll(subjects);
        _subjectsData!['studyAbroadExams'] = existing.toList();
        for (final sub in subjects) {
          if (!_rates.any((r) => r['subject'] == sub && r['board'] == 'Study Abroad')) {
            _rates.add({'subject': sub, 'board': 'Study Abroad', 'grade': '', 'inr': 0, 'international': 0});
          }
        }
        break;

      case 'Non-Academic':
        final type = result['type'] as String;
        _subjectsData!['nonAcademic'] ??= {};
        if (type == 'Music') {
          final musicType = result['musicType'] as String;
          _subjectsData!['nonAcademic']['music'] ??= {};
          final existing = Set<String>.from(_subjectsData!['nonAcademic']['music'][musicType] ?? [])..addAll(subjects);
          _subjectsData!['nonAcademic']['music'][musicType] = existing.toList();
        } else if (type == 'Dance') {
          final existing = Set<String>.from(_subjectsData!['nonAcademic']['dance'] ?? [])..addAll(subjects);
          _subjectsData!['nonAcademic']['dance'] = existing.toList();
        } else if (type == 'Coding & Computers') {
          final existing = Set<String>.from(_subjectsData!['nonAcademic']['coding'] ?? [])..addAll(subjects);
          _subjectsData!['nonAcademic']['coding'] = existing.toList();
        } else {
          final existing = Set<String>.from(_subjectsData!['nonAcademic']['activities'] ?? [])..add(type);
          _subjectsData!['nonAcademic']['activities'] = existing.toList();
        }
        for (final sub in subjects) {
          if (!_rates.any((r) => r['subject'] == sub && r['board'] == type)) {
            _rates.add({'subject': sub, 'board': type, 'grade': 'Non-Academic', 'inr': 0, 'international': 0});
          }
        }
        break;

      case 'Language Learning':
        final existing = Set<String>.from(_subjectsData!['languages'] ?? [])..addAll(subjects);
        _subjectsData!['languages'] = existing.toList();
        for (final sub in subjects) {
          if (!_rates.any((r) => r['subject'] == sub && r['board'] == 'Language')) {
            _rates.add({'subject': sub, 'board': 'Language', 'grade': '', 'inr': 0, 'international': 0});
          }
        }
        break;
    }

    // Save to DB
    await TutorProfileService.updateProfile(_tutorId!, {'subjects': _subjectsData});

    setState(() {
      _subjects = _extractSubjectNames(_subjectsData!);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${subjects.length} item${subjects.length > 1 ? 's' : ''} under $level')),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: cs.tertiary),
        const SizedBox(width: 8),
        Text(title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
