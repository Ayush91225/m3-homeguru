import 'package:flutter/material.dart';
import '../../../widgets/requests/tutor_request_model.dart';
import '../../../widgets/requests/tutor_request_tile.dart';
import '../../../services/tutor_data_model.dart';

class TutorRequestsTab extends StatefulWidget {
  const TutorRequestsTab({super.key});

  @override
  State<TutorRequestsTab> createState() => _TutorRequestsTabState();
}

class _TutorRequestsTabState extends State<TutorRequestsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TutorRequestStatus? _filterStatus;
  String? _filterStudent;
  DateTime? _filterFromDate;
  DateTime? _filterToDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<TutorBookingRequest> _buildRequests() {
    final raw = TutorData.of(context).pendingRequests;
    if (raw.isEmpty) return [];
    return raw.map((r) => TutorBookingRequest(
      id: r['id']?.toString() ?? '',
      studentName: r['studentName']?.toString() ?? '',
      studentImage: r['studentImage']?.toString() ?? '',
      subject: r['subject']?.toString() ?? '',
      level: r['level']?.toString() ?? '',
      type: switch (r['type']?.toString()) { 'demo' => TutorRequestType.demo, 'reschedule' => TutorRequestType.reschedule, _ => TutorRequestType.paid },
      status: switch (r['status']?.toString()) { 'accepted' => TutorRequestStatus.accepted, 'declined' => TutorRequestStatus.declined, _ => TutorRequestStatus.pending },
      requestedAt: DateTime.tryParse(r['requestedAt']?.toString() ?? '') ?? DateTime.now(),
      respondedAt: r['respondedAt'] != null ? DateTime.tryParse(r['respondedAt'].toString()) : null,
      preferredSlot: r['preferredSlot']?.toString(),
      schedule: r['schedule']?.toString(),
      totalSessions: r['totalSessions'] as int?,
      perHourRate: (r['perHourRate'] as num?)?.toDouble(),
      classesPerWeek: r['classesPerWeek'] as int?,
      totalPrice: (r['totalPrice'] as num?)?.toDouble(),
      inHandAmount: (r['inHandAmount'] as num?)?.toDouble(),
      note: r['note']?.toString(),
      originalDate: r['originalDate'] != null ? DateTime.tryParse(r['originalDate'].toString()) : null,
      originalTime: r['originalTime']?.toString(),
      newDate: r['newDate'] != null ? DateTime.tryParse(r['newDate'].toString()) : null,
      newTime: r['newTime']?.toString(),
    )).toList();
  }

  void _handleAccept(String id) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request accepted'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() {});
  }

  void _handleDecline(String id) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request declined'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() {});
  }

  List<TutorBookingRequest> _applyFilters(List<TutorBookingRequest> requests) {
    return requests.where((r) {
      if (_filterStatus != null && r.status != _filterStatus) return false;
      if (_filterStudent != null && r.studentName != _filterStudent) return false;
      if (_filterFromDate != null && r.requestedAt.isBefore(_filterFromDate!)) return false;
      if (_filterToDate != null && r.requestedAt.isAfter(_filterToDate!.add(const Duration(days: 1)))) return false;
      return true;
    }).toList();
  }

  bool get _hasFilters => _filterStatus != null || _filterStudent != null || _filterFromDate != null || _filterToDate != null;

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filterFromDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _filterFromDate = picked);
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filterToDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _filterToDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final allRequests = _buildRequests();
    final paidRequests = _applyFilters(allRequests.where((r) => r.type == TutorRequestType.paid).toList());
    final demoRequests = _applyFilters(allRequests.where((r) => r.type == TutorRequestType.demo).toList());
    final rescheduleRequests = _applyFilters(allRequests.where((r) => r.type == TutorRequestType.reschedule).toList());

    final allStudents = allRequests
        .map((r) => r.studentName)
        .toSet()
        .toList()
      ..sort();

    return Column(
      children: [
        if (_hasFilters)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cs.tertiaryContainer.withValues(alpha: 0.3),
              border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
            ),
            child: Row(
              children: [
                Icon(Icons.filter_list_rounded, size: 16, color: cs.tertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Filters active',
                    style: tt.labelSmall?.copyWith(color: cs.onSurface),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _filterStatus = null;
                    _filterStudent = null;
                    _filterFromDate = null;
                    _filterToDate = null;
                  }),
                  child: Text('Clear All', style: tt.labelSmall?.copyWith(color: cs.tertiary)),
                ),
              ],
            ),
          ),
        _FilterBar(
          filterStatus: _filterStatus,
          filterStudent: _filterStudent,
          filterFromDate: _filterFromDate,
          filterToDate: _filterToDate,
          students: allStudents,
          onStatusChanged: (v) => setState(() => _filterStatus = v),
          onStudentChanged: (v) => setState(() => _filterStudent = v),
          onFromDateTap: _pickFromDate,
          onToDateTap: _pickToDate,
        ),
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: cs.tertiary,
            unselectedLabelColor: cs.onSurfaceVariant,
            indicatorColor: cs.tertiary,
            labelStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'Paid (${paidRequests.length})'),
              Tab(text: 'Demo (${demoRequests.length})'),
              Tab(text: 'Reschd (${rescheduleRequests.length})'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRequestList(paidRequests),
              _buildRequestList(demoRequests),
              _buildRequestList(rescheduleRequests),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequestList(List<TutorBookingRequest> requests) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'No requests',
              style: tt.titleLarge?.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Student requests will appear here',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 32),
      itemCount: requests.length,
      itemBuilder: (context, i) => TutorRequestTile(
        request: requests[i],
        onAccept: () => _handleAccept(requests[i].id),
        onDecline: () => _handleDecline(requests[i].id),
      ),
    );
  }
}


class _FilterBar extends StatelessWidget {
  final TutorRequestStatus? filterStatus;
  final String? filterStudent;
  final DateTime? filterFromDate;
  final DateTime? filterToDate;
  final List<String> students;
  final ValueChanged<TutorRequestStatus?> onStatusChanged;
  final ValueChanged<String?> onStudentChanged;
  final VoidCallback onFromDateTap;
  final VoidCallback onToDateTap;

  const _FilterBar({
    required this.filterStatus,
    required this.filterStudent,
    required this.filterFromDate,
    required this.filterToDate,
    required this.students,
    required this.onStatusChanged,
    required this.onStudentChanged,
    required this.onFromDateTap,
    required this.onToDateTap,
  });

  String _fmtDate(DateTime d) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
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
          _buildChip(
            context,
            icon: Icons.radio_button_checked_rounded,
            label: filterStatus == TutorRequestStatus.pending
                ? 'Pending'
                : filterStatus == TutorRequestStatus.accepted
                    ? 'Accepted'
                    : filterStatus == TutorRequestStatus.declined
                        ? 'Declined'
                        : 'Status',
            active: filterStatus != null,
            onTap: () {
              if (filterStatus == null) {
                onStatusChanged(TutorRequestStatus.pending);
              } else if (filterStatus == TutorRequestStatus.pending) {
                onStatusChanged(TutorRequestStatus.accepted);
              } else if (filterStatus == TutorRequestStatus.accepted) {
                onStatusChanged(TutorRequestStatus.declined);
              } else {
                onStatusChanged(null);
              }
            },
          ),
          const SizedBox(width: 8),
          _DropdownChip(
            icon: Icons.person_outline_rounded,
            label: filterStudent ?? 'Student',
            active: filterStudent != null,
            items: students,
            value: filterStudent,
            onChanged: onStudentChanged,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            icon: Icons.calendar_today_rounded,
            label: filterFromDate != null ? 'From: ${_fmtDate(filterFromDate!)}' : 'From Date',
            active: filterFromDate != null,
            onTap: onFromDateTap,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            icon: Icons.event_rounded,
            label: filterToDate != null ? 'To: ${_fmtDate(filterToDate!)}' : 'To Date',
            active: filterToDate != null,
            onTap: onToDateTap,
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
          color: active ? cs.tertiaryContainer : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: active ? cs.onTertiaryContainer : cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: active ? cs.onTertiaryContainer : cs.onSurfaceVariant,
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
          color: active ? cs.tertiaryContainer : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: active ? cs.onTertiaryContainer : cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: active ? cs.onTertiaryContainer : cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down_rounded, size: 16, color: active ? cs.onTertiaryContainer : cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
