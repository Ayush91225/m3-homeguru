import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/tutor_profile_service.dart';

class TutorProfileEditScreen extends StatefulWidget {
  const TutorProfileEditScreen({super.key});

  @override
  State<TutorProfileEditScreen> createState() => _TutorProfileEditScreenState();
}

class _TutorProfileEditScreenState extends State<TutorProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;
  bool _saving = false;

  final _photoCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _youtubeCtrl = TextEditingController();

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

  String? _tutorId;
  List<String> _subjects = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _photoCtrl.dispose();
    _experienceCtrl.dispose();
    _youtubeCtrl.dispose();
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
      _photoCtrl.text = data['profilePhoto'] ?? '';
      _experienceCtrl.text = data['experience'] ?? '';
      _youtubeCtrl.text = data['youtubeVideoLink'] ?? '';

      // Parse subjects from onboarding data
      if (data['subjects'] != null) {
        final subjectsData = data['subjects'] as Map<String, dynamic>;
        _subjects = _extractSubjectNames(subjectsData);
      }

      // Parse rates
      if (data['rates'] != null) {
        _rates = (data['rates'] as List).map((r) => Map<String, dynamic>.from(r)).toList();
      } else {
        // Pre-populate rate entries from subjects
        _rates = _subjects.map((s) => {'subject': s, 'inr': 0, 'international': 0}).toList();
      }

      // Parse availability
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

    final result = await TutorProfileService.updateProfile(_tutorId!, {
      'profilePhoto': _photoCtrl.text.trim(),
      'experience': _experienceCtrl.text.trim(),
      'youtubeVideoLink': _youtubeCtrl.text.trim(),
      'rates': _rates,
      'availability': _availability,
    });

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
        if (isComplete) Navigator.pop(context, true);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Profile Photo URL
            _SectionHeader(title: 'Profile Photo', icon: Icons.photo_camera_rounded),
            const SizedBox(height: 8),
            TextFormField(
              controller: _photoCtrl,
              decoration: const InputDecoration(
                hintText: 'Paste photo URL',
                prefixIcon: Icon(Icons.link_rounded),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            if (_photoCtrl.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _photoCtrl.text,
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120, width: 120,
                    color: cs.errorContainer,
                    child: Icon(Icons.broken_image, color: cs.error),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Experience
            _SectionHeader(title: 'Experience', icon: Icons.work_rounded),
            const SizedBox(height: 8),
            TextFormField(
              controller: _experienceCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'e.g. 5 years teaching Mathematics at DPS, 2 years online tutoring for JEE...',
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),

            const SizedBox(height: 32),

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

            const SizedBox(height: 32),

            // Rates
            _SectionHeader(title: 'Subject-wise Rates (per hour)', icon: Icons.currency_rupee_rounded),
            const SizedBox(height: 12),
            ..._buildRatesSection(cs, tt),

            const SizedBox(height: 32),

            // Availability
            _SectionHeader(title: 'Availability', icon: Icons.calendar_month_rounded),
            const SizedBox(height: 12),
            ..._buildAvailabilitySection(cs, tt),

            const SizedBox(height: 40),

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
    );
  }

  List<Widget> _buildRatesSection(ColorScheme cs, TextTheme tt) {
    final widgets = <Widget>[];
    for (int i = 0; i < _rates.length; i++) {
      widgets.add(Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(_rates[i]['subject'] ?? 'Subject ${i + 1}',
                      style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: cs.error, size: 20),
                  onPressed: () => setState(() => _rates.removeAt(i)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _rates[i]['inr']?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '₹ INR/hr',
                      isDense: true,
                    ),
                    onChanged: (v) => _rates[i]['inr'] = int.tryParse(v) ?? 0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: _rates[i]['international']?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '\$ USD/hr',
                      isDense: true,
                    ),
                    onChanged: (v) => _rates[i]['international'] = int.tryParse(v) ?? 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ));
    }

    widgets.add(OutlinedButton.icon(
      onPressed: () => _showAddSubjectDialog(),
      icon: const Icon(Icons.add, size: 18),
      label: const Text('Add Subject Rate'),
    ));

    return widgets;
  }

  void _showAddSubjectDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Subject'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Subject name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                setState(() => _rates.add({'subject': ctrl.text.trim(), 'inr': 0, 'international': 0}));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
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

    setState(() {
      _availability[day]!.add({
        'start': '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}',
        'end': '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}',
      });
    });
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
