import 'package:flutter/material.dart';
import 'class_content_screen.dart';

// ── Session model ─────────────────────────────────────────────────────────────

enum SessionType { demo, paid, paidDemo }
enum SessionStatus { conducted, upcoming, cancelled }

class SessionData {
  final String id;
  final String title;
  final String subject;
  final String tutor;
  final String tutorImage;
  final DateTime scheduledAt;
  final String duration;
  final SessionType type;
  final SessionStatus status;
  final double? paidAmount;
  final String meetingCode;
  final int? classNumber;    // e.g. 12
  final int? totalClasses;   // e.g. 100
  final int files;
  final String quiz;

  const SessionData({
    required this.id,
    required this.title,
    required this.subject,
    required this.tutor,
    required this.tutorImage,
    required this.scheduledAt,
    required this.duration,
    required this.type,
    required this.status,
    this.paidAmount,
    required this.meetingCode,
    this.classNumber,
    this.totalClasses,
    this.files = 0,
    this.quiz = '0/0',
  });
}

// ── Mock data ─────────────────────────────────────────────────────────────────

// Tutor definitions
const _tutors = [
  (
    name: 'Vikram Singh',
    image: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop',
    subject: 'IELTS',
    price: 799.0,
    totalClasses: 50,
  ),
  (
    name: 'Priya Sharma',
    image: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop',
    subject: 'JEE Advanced',
    price: 999.0,
    totalClasses: 100,
  ),
  (
    name: 'Ananya Reddy',
    image: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop',
    subject: 'CBSE Grade 11-12',
    price: 649.0,
    totalClasses: 30,
  ),
  (
    name: 'Meera Patel',
    image: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop',
    subject: 'NEET',
    price: 1199.0,
    totalClasses: 20,
  ),
  (
    name: 'Rajesh Kumar',
    image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
    subject: 'JEE Mains',
    price: 899.0,
    totalClasses: 60,
  ),
];

// Per-tutor session titles (conducted)
const _titles = {
  'Vikram Singh': [
    'Speaking Practice — Introductions', 'Listening Skills: Lecture Format',
    'Reading Comprehension Strategies', 'Writing Task 1: Graphs & Charts',
    'Writing Task 2: Opinion Essays', 'Grammar for IELTS Band 7+',
    'Vocabulary Building Session', 'Mock Test — Full Paper',
    'Pronunciation & Fluency Drill', 'Academic Word List Deep Dive',
    'Paraphrasing Techniques', 'Cohesion & Coherence in Writing',
    'Listening: Multiple Choice Practice', 'Speaking Part 2 — Cue Cards',
    'Reading: True/False/Not Given', 'Writing Feedback & Corrections',
    'Idioms & Collocations', 'Time Management in Exam',
    'Band 8 Sample Answers Review', 'Error Analysis Session',
    'Formal vs Informal Register', 'Skimming & Scanning Techniques',
    'Complex Sentence Structures', 'Passive Voice in Academic Writing',
    'Discourse Markers Practice', 'Spelling & Punctuation Rules',
    'Listening: Diagram Completion', 'Speaking Part 3 — Discussion',
    'Reading: Matching Headings', 'Final Mock & Score Prediction',
  ],
  'Priya Sharma': [
    'Limits & Continuity', 'Differentiation — Chain Rule',
    'Integration by Parts', 'Differential Equations Intro',
    'Vectors & 3D Geometry', 'Matrices & Determinants',
    'Probability & Statistics', 'Complex Numbers',
    'Sequences & Series', 'Binomial Theorem',
    'Conic Sections — Ellipse', 'Conic Sections — Hyperbola',
    'Trigonometric Identities', 'Inverse Trigonometry',
    'Applications of Derivatives', 'Definite Integrals',
    'Area Under Curves', 'Linear Programming',
    'Relations & Functions', 'Sets & Logic',
    'Permutations & Combinations', 'Mathematical Induction',
    'Straight Lines & Circles', 'Parabola Problems',
    'JEE Advanced Paper 1 Mock', 'JEE Advanced Paper 2 Mock',
    'Error Analysis — Calculus', 'Revision: Algebra',
    'Revision: Coordinate Geometry', 'Final Strategy Session',
  ],
  'Ananya Reddy': [
    'Organic Chemistry — Basics', 'Hydrocarbons & Nomenclature',
    'Alcohols, Phenols & Ethers', 'Aldehydes & Ketones',
    'Carboxylic Acids & Derivatives', 'Amines & Diazonium Salts',
    'Biomolecules Overview', 'Polymers & Chemistry in Everyday Life',
    'Chemical Bonding & Structure', 'States of Matter',
    'Thermodynamics — First Law', 'Thermodynamics — Second Law',
    'Equilibrium & Le Chatelier', 'Electrochemistry Basics',
    'Kinetics & Rate Laws', 'Surface Chemistry',
    'p-Block Elements', 'd & f Block Elements',
    'Coordination Compounds', 'Haloalkanes & Haloarenes',
    'Environmental Chemistry', 'Solid State',
    'Solutions & Colligative Properties', 'Redox Reactions',
    'Hydrogen & s-Block Elements', 'General Principles of Extraction',
    'CBSE Board Paper 2023 Review', 'CBSE Board Paper 2024 Review',
    'Revision: Organic Reactions', 'Final Mock Test',
  ],
  'Meera Patel': [
    'Cell Structure & Function', 'Cell Division — Mitosis & Meiosis',
    'Biomolecules: Proteins & Enzymes', 'Photosynthesis in Detail',
    'Respiration — Glycolysis & Krebs', 'Plant Growth & Development',
    'Reproduction in Flowering Plants', 'Human Reproduction',
    'Genetics — Mendelian Laws', 'Molecular Basis of Inheritance',
    'Evolution & Natural Selection', 'Human Health & Disease',
    'Microbes in Human Welfare', 'Biotechnology Principles',
    'Biotechnology Applications', 'Organisms & Populations',
    'Ecosystem & Energy Flow', 'Biodiversity & Conservation',
    'Environmental Issues', 'Structural Organisation in Animals',
    'Digestion & Absorption', 'Breathing & Gas Exchange',
    'Body Fluids & Circulation', 'Excretory Products & Elimination',
    'Locomotion & Movement', 'Neural Control & Coordination',
    'Chemical Coordination', 'NEET Mock Test — Biology',
    'Revision: Plant Physiology', 'Final Score Booster',
  ],
  'Rajesh Kumar': [
    'Kinematics — 1D Motion', 'Kinematics — 2D Projectile',
    'Laws of Motion & Friction', 'Work, Energy & Power',
    'Rotational Motion & Torque', 'Gravitation',
    'Properties of Solids & Fluids', 'Thermal Properties of Matter',
    'Thermodynamics', 'Kinetic Theory of Gases',
    'Simple Harmonic Motion', 'Waves & Sound',
    'Electrostatics — Coulomb\'s Law', 'Electric Potential & Capacitance',
    'Current Electricity & Ohm\'s Law', 'Magnetic Effects of Current',
    'Magnetism & Matter', 'Electromagnetic Induction',
    'Alternating Current', 'Electromagnetic Waves',
    'Ray Optics & Optical Instruments', 'Wave Optics',
    'Dual Nature of Radiation', 'Atoms & Nuclei',
    'Semiconductor Devices', 'Communication Systems',
    'JEE Mains Mock Test 1', 'JEE Mains Mock Test 2',
    'Revision: Mechanics', 'Final Strategy & Exam Tips',
  ],
};

const _durations = ['45m', '1h', '1h 15m', '1h 30m', '1h 45m', '2h', '2h 30m'];
const _quizScores = ['0/0', '5/10', '6/10', '7/10', '8/10', '9/10', '10/10',
                     '8/15', '10/15', '12/15', '14/15', '15/15',
                     '6/20', '12/20', '16/20', '18/20', '20/20'];

List<SessionData> _generateSessions() {
  final now = DateTime.now();
  final sessions = <SessionData>[];
  int idCounter = 1;
  int codeCounter = 1000;

  for (final tutor in _tutors) {
    final titles = _titles[tutor.name]!; // 30 titles per tutor

    // ── 30 conducted sessions (spread over past ~180 days) ──
    for (int i = 0; i < 30; i++) {
      final classNum = i + 1;
      final daysAgo = (i * 6) + 1; // every ~6 days
      final hoursOffset = (i % 5) * 2;
      final isDemo = classNum == 1;
      final isPaidDemo = classNum == 2;
      final type = isDemo
          ? SessionType.demo
          : isPaidDemo
              ? SessionType.paidDemo
              : SessionType.paid;
      final filesCount = (i % 4 == 0) ? 0 : (i % 3) + 1;
      final quizStr = isDemo ? '0/0' : _quizScores[(i + idCounter) % _quizScores.length];

      sessions.add(SessionData(
        id: '${idCounter++}',
        title: titles[i],
        subject: tutor.subject,
        tutor: tutor.name,
        tutorImage: tutor.image,
        scheduledAt: now.subtract(Duration(days: daysAgo, hours: hoursOffset)),
        duration: _durations[(i + idCounter) % _durations.length],
        type: type,
        status: SessionStatus.conducted,
        paidAmount: isDemo ? null : (isPaidDemo ? 99 : tutor.price),
        meetingCode: 'HG-${codeCounter++}',
        classNumber: classNum,
        totalClasses: tutor.totalClasses,
        files: filesCount,
        quiz: quizStr,
      ));
    }

    // ── 10 upcoming sessions (spread over next ~60 days) ──
    for (int i = 0; i < 10; i++) {
      final classNum = 31 + i;
      final daysAhead = (i * 6) + 1;
      final hoursOffset = (i % 4) * 3;

      sessions.add(SessionData(
        id: '${idCounter++}',
        title: titles[i % titles.length], // reuse titles for upcoming
        subject: tutor.subject,
        tutor: tutor.name,
        tutorImage: tutor.image,
        scheduledAt: now.add(Duration(days: daysAhead, hours: hoursOffset)),
        duration: _durations[(i + idCounter) % _durations.length],
        type: SessionType.paid,
        status: SessionStatus.upcoming,
        paidAmount: tutor.price,
        meetingCode: 'HG-${codeCounter++}',
        classNumber: classNum,
        totalClasses: tutor.totalClasses,
      ));
    }
  }

  return sessions;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class SessionsListingScreen extends StatefulWidget {
  const SessionsListingScreen({super.key, this.initialTutor});
  final String? initialTutor;

  @override
  State<SessionsListingScreen> createState() => _SessionsListingScreenState();
}

class _SessionsListingScreenState extends State<SessionsListingScreen> {
  final List<SessionData> _all = _generateSessions();

  DateTime? _filterDate;
  String? _filterSubject;
  late String? _filterTutor;
  SessionStatus? _filterStatus;

  List<SessionData> get _filtered {
    return _all.where((s) {
      if (_filterDate != null) {
        final d = _filterDate!;
        if (s.scheduledAt.year != d.year ||
            s.scheduledAt.month != d.month ||
            s.scheduledAt.day != d.day) { return false; }
      }
      if (_filterSubject != null && s.subject != _filterSubject) return false;
      if (_filterTutor != null && s.tutor != _filterTutor) return false;
      if (_filterStatus != null && s.status != _filterStatus) return false;
      return true;
    }).toList()
      ..sort((a, b) {
        // conducted first (most recent → oldest), then upcoming (soonest first)
        final aOrder = a.status == SessionStatus.conducted ? 0 : 1;
        final bOrder = b.status == SessionStatus.conducted ? 0 : 1;
        if (aOrder != bOrder) return aOrder.compareTo(bOrder);
        if (a.status == SessionStatus.conducted) {
          return a.scheduledAt.compareTo(b.scheduledAt); // oldest first
        }
        return a.scheduledAt.compareTo(b.scheduledAt); // soonest first
      });
  }

  List<String> get _subjects => _all.map((s) => s.subject).toSet().toList()..sort();
  List<String> get _tutors => _all.map((s) => s.tutor).toSet().toList()..sort();

  @override
  void initState() {
    super.initState();
    _filterTutor = widget.initialTutor;
  }

  bool get _hasFilters => _filterDate != null || _filterSubject != null || _filterTutor != null || _filterStatus != null;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) { setState(() => _filterDate = picked); }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final sessions = _filtered;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('All Sessions', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
        actions: [
          if (_hasFilters)
            TextButton(
              onPressed: () => setState(() {
                _filterDate = null;
                _filterSubject = null;
                _filterTutor = null;
                _filterStatus = null;
              }),
              child: Text('Clear', style: tt.labelMedium?.copyWith(color: cs.primary)),
            ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(
            filterDate: _filterDate,
            filterSubject: _filterSubject,
            filterTutor: _filterTutor,
            filterStatus: _filterStatus,
            subjects: _subjects,
            tutors: _tutors,
            onDateTap: _pickDate,
            onSubjectChanged: (v) => setState(() => _filterSubject = v),
            onTutorChanged: (v) => setState(() => _filterTutor = v),
            onStatusChanged: (v) => setState(() => _filterStatus = v),
          ),
          Expanded(
            child: sessions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: cs.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text('No sessions found', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 32),
                    itemCount: sessions.length,
                    itemBuilder: (context, i) => _SessionTile(session: sessions[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Filter bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final DateTime? filterDate;
  final String? filterSubject;
  final String? filterTutor;
  final SessionStatus? filterStatus;
  final List<String> subjects;
  final List<String> tutors;
  final VoidCallback onDateTap;
  final ValueChanged<String?> onSubjectChanged;
  final ValueChanged<String?> onTutorChanged;
  final ValueChanged<SessionStatus?> onStatusChanged;

  const _FilterBar({
    required this.filterDate,
    required this.filterSubject,
    required this.filterTutor,
    required this.filterStatus,
    required this.subjects,
    required this.tutors,
    required this.onDateTap,
    required this.onSubjectChanged,
    required this.onTutorChanged,
    required this.onStatusChanged,
  });

  String _fmtDate(DateTime d) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Date filter chip
          _buildChip(
            context,
            icon: Icons.calendar_today_rounded,
            label: filterDate != null ? _fmtDate(filterDate!) : 'Date',
            active: filterDate != null,
            onTap: onDateTap,
          ),
          const SizedBox(width: 8),
          // Subject dropdown chip
          _DropdownChip(
            icon: Icons.subject_rounded,
            label: filterSubject ?? 'Subject',
            active: filterSubject != null,
            items: subjects,
            value: filterSubject,
            onChanged: onSubjectChanged,
          ),
          const SizedBox(width: 8),
          // Tutor dropdown chip
          _DropdownChip(
            icon: Icons.person_outline_rounded,
            label: filterTutor ?? 'Tutor',
            active: filterTutor != null,
            items: tutors,
            value: filterTutor,
            onChanged: onTutorChanged,
          ),
          const SizedBox(width: 8),
          // Status chip — cycles: null → conducted → upcoming → null
          _buildChip(
            context,
            icon: Icons.radio_button_checked_rounded,
            label: filterStatus == SessionStatus.conducted
                ? 'Conducted'
                : filterStatus == SessionStatus.upcoming
                    ? 'Upcoming'
                    : 'Status',
            active: filterStatus != null,
            onTap: () {
              if (filterStatus == null) {
                onStatusChanged(SessionStatus.conducted);
              } else if (filterStatus == SessionStatus.conducted) {
                onStatusChanged(SessionStatus.upcoming);
              } else {
                onStatusChanged(null);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, {
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? cs.primaryContainer : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: active ? cs.onPrimaryContainer : cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: active ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _DropdownChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return PopupMenuButton<String>(
      initialValue: value,
      onSelected: onChanged,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: cs.surfaceContainer,
      itemBuilder: (_) => [
        PopupMenuItem(value: null, child: Text('All', style: TextStyle(color: cs.onSurface))),
        ...items.map((s) => PopupMenuItem(value: s, child: Text(s, style: TextStyle(color: cs.onSurface)))),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? cs.primaryContainer : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: active ? cs.onPrimaryContainer : cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: active ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down_rounded, size: 16, color: active ? cs.onPrimaryContainer : cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ── Session tile (chat-style) ─────────────────────────────────────────────────

class _SessionTile extends StatelessWidget {
  final SessionData session;
  const _SessionTile({required this.session});

  String _fmtDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final p = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day} ${months[d.month - 1]} ${d.year}  $h:$m $p';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isConducted = session.status == SessionStatus.conducted;

    return Opacity(
      opacity: session.status == SessionStatus.upcoming ? 0.45 : 1.0,
      child: InkWell(
      onTap: isConducted
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClassContentScreen(session: {
                    'title': session.title,
                    'subject': session.subject,
                    'tutor': session.tutor,
                    'tutorImage': session.tutorImage,
                    'completedAt': session.scheduledAt,
                    'files': session.files,
                    'quiz': session.quiz,
                    'duration': session.duration,
                  }),
                ),
              )
          : null,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: cs.surfaceContainerHighest,
                  backgroundImage: NetworkImage(session.tutorImage),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: title + date
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              session.title,
                              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _fmtDate(session.scheduledAt),
                            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Row 2: subject (primary color) + tutor
                      Row(
                        children: [
                          Text(
                            session.subject,
                            style: tt.labelSmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '  ·  ${session.tutor}',
                            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Row 3: tags row
                      Row(
                        children: [
                          _StatusTag(status: session.status),
                          const SizedBox(width: 6),
                          _TypeTag(type: session.type, paidAmount: session.paidAmount),
                          if (session.classNumber != null && session.totalClasses != null) ...[
                            const SizedBox(width: 6),
                            _MiniTag(
                              label: 'Class ${session.classNumber}/${session.totalClasses}',
                              color: cs.onSurfaceVariant,
                              bg: cs.surfaceContainerLow,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Row 4: meta items
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          _MetaItem(icon: Icons.access_time_rounded, label: session.duration),
                          _MetaItem(icon: Icons.meeting_room_outlined, label: session.meetingCode),
                          if (isConducted && session.files > 0)
                            _MetaItem(icon: Icons.folder_outlined, label: '${session.files} files'),
                          if (isConducted && session.quiz != '0/0')
                            _MetaItem(icon: Icons.quiz_outlined, label: session.quiz),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            indent: 16 + 48 + 12, // align with text
            color: cs.outlineVariant.withValues(alpha: 0.3),
          ),
        ],
      ),
    ),
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────

class _MiniTag extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const _MiniTag({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  final SessionStatus status;
  const _StatusTag({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (label, color, bg) = switch (status) {
      SessionStatus.conducted => ('Conducted', cs.primary, cs.primaryContainer),
      SessionStatus.upcoming  => ('Upcoming', cs.tertiary, cs.tertiaryContainer),
      SessionStatus.cancelled => ('Cancelled', cs.error, cs.errorContainer),
    };
    return _MiniTag(label: label, color: color, bg: bg);
  }
}

class _TypeTag extends StatelessWidget {
  final SessionType type;
  final double? paidAmount;
  const _TypeTag({required this.type, this.paidAmount});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = switch (type) {
      SessionType.demo     => 'Demo',
      SessionType.paid     => 'Paid · ₹${paidAmount?.toInt()}',
      SessionType.paidDemo => 'Paid Demo · ₹99',
    };
    final (color, bg) = type == SessionType.demo
        ? (cs.onSurfaceVariant, cs.surfaceContainerLow)
        : (cs.tertiary, cs.tertiaryContainer.withValues(alpha: 0.5));
    return _MiniTag(label: label, color: color, bg: bg);
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
      ],
    );
  }
}
