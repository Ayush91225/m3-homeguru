import 'package:flutter/material.dart';
import 'class_content_screen.dart';
import '../../services/session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

// ── Screen ────────────────────────────────────────────────────────────────────

class SessionsListingScreen extends StatefulWidget {
  const SessionsListingScreen({super.key, this.initialTutor, this.isTutor = false});
  final String? initialTutor;
  final bool isTutor;

  @override
  State<SessionsListingScreen> createState() => _SessionsListingScreenState();
}

class _SessionsListingScreenState extends State<SessionsListingScreen> {
  List<SessionData> _all = [];
  bool _loading = true;

  DateTime? _filterDate;
  String? _filterSubject;
  late String? _filterTutor;
  SessionStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _filterTutor = widget.initialTutor;
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) {
        setState(() => _loading = false);
        return;
      }

      final sessions = await SessionService.fetchSessions(
        tutorId: widget.isTutor ? userId : null,
        learnerId: widget.isTutor ? null : userId,
      );

      final mapped = sessions.map((s) {
        final scheduledAt = DateTime.tryParse(s['scheduledAt']?.toString() ?? '') ?? DateTime.now();
        final duration = s['duration'] as int? ?? 60;
        final status = s['status']?.toString() ?? 'upcoming';
        final type = s['type']?.toString() ?? 'demo';

        return SessionData(
          id: s['sessionId']?.toString() ?? '',
          title: s['subject']?.toString() ?? 'Session',
          subject: s['subject']?.toString() ?? '',
          tutor: widget.isTutor ? (s['learnerName']?.toString() ?? 'Student') : (s['tutorName']?.toString() ?? 'Tutor'),
          tutorImage: widget.isTutor ? (s['learnerImage']?.toString() ?? '') : (s['tutorImage']?.toString() ?? ''),
          scheduledAt: scheduledAt,
          duration: '${duration}m',
          type: type == 'paid' ? SessionType.paid : type == 'paid-demo' ? SessionType.paidDemo : SessionType.demo,
          status: status == 'conducted' ? SessionStatus.conducted : status == 'cancelled' ? SessionStatus.cancelled : SessionStatus.upcoming,
          paidAmount: (s['price'] as num?)?.toDouble(),
          meetingCode: s['meetingId']?.toString() ?? '',
          classNumber: s['sessionNumber'] as int?,
          totalClasses: s['totalSessions'] as int?,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _all = mapped;
          _loading = false;
        });
      }
    } catch (e) {
      print('Error loading sessions: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                  isTutor: widget.isTutor,
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
                          itemBuilder: (context, i) => _SessionTile(session: sessions[i], isTutor: widget.isTutor),
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
  final bool isTutor;

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
    this.isTutor = false,
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
            isTutor: isTutor,
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
            isTutor: isTutor,
          ),
          const SizedBox(width: 8),
          // Tutor dropdown chip
          _DropdownChip(
            icon: Icons.person_outline_rounded,
            label: filterTutor ?? (isTutor ? 'Student' : 'Tutor'),
            active: filterTutor != null,
            items: tutors,
            value: filterTutor,
            onChanged: onTutorChanged,
            isTutor: isTutor,
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
            isTutor: isTutor,
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
    bool isTutor = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? (isTutor ? cs.tertiaryContainer : cs.primaryContainer)
              : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: active
                ? (isTutor ? cs.onTertiaryContainer : cs.onPrimaryContainer)
                : cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: active
                    ? (isTutor ? cs.onTertiaryContainer : cs.onPrimaryContainer)
                    : cs.onSurfaceVariant,
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
  final bool isTutor;

  const _DropdownChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.items,
    required this.value,
    required this.onChanged,
    this.isTutor = false,
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
          color: active
              ? (isTutor ? cs.tertiaryContainer : cs.primaryContainer)
              : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: active
                ? (isTutor ? cs.onTertiaryContainer : cs.onPrimaryContainer)
                : cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: active
                    ? (isTutor ? cs.onTertiaryContainer : cs.onPrimaryContainer)
                    : cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down_rounded, size: 16, color: active
                ? (isTutor ? cs.onTertiaryContainer : cs.onPrimaryContainer)
                : cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ── Session tile (chat-style) ─────────────────────────────────────────────────

class _SessionTile extends StatelessWidget {
  final SessionData session;
  final bool isTutor;
  const _SessionTile({required this.session, this.isTutor = false});

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
                  backgroundImage: session.tutorImage.isNotEmpty
                      ? NetworkImage(session.tutorImage)
                      : null,
                  child: session.tutorImage.isEmpty
                      ? Icon(Icons.person, size: 24, color: cs.onSurfaceVariant)
                      : null,
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
                              color: isTutor ? cs.tertiary : cs.primary,
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
                          _StatusTag(status: session.status, isTutor: isTutor),
                          const SizedBox(width: 6),
                          _TypeTag(type: session.type, paidAmount: session.paidAmount, isTutor: isTutor),
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
  final bool isTutor;
  const _StatusTag({required this.status, this.isTutor = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (label, color, bg) = switch (status) {
      SessionStatus.conducted => ('Conducted', isTutor ? cs.tertiary : cs.primary, isTutor ? cs.tertiaryContainer : cs.primaryContainer),
      SessionStatus.upcoming  => ('Upcoming', cs.tertiary, cs.tertiaryContainer),
      SessionStatus.cancelled => ('Cancelled', cs.error, cs.errorContainer),
    };
    return _MiniTag(label: label, color: color, bg: bg);
  }
}

class _TypeTag extends StatelessWidget {
  final SessionType type;
  final double? paidAmount;
  final bool isTutor;
  const _TypeTag({required this.type, this.paidAmount, this.isTutor = false});

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
        : (isTutor ? cs.tertiary : cs.primary, (isTutor ? cs.tertiaryContainer : cs.primaryContainer).withValues(alpha: 0.5));
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
