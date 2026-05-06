import 'package:flutter/material.dart';
import 'request_model.dart';

class RequestFilterBar extends StatelessWidget {
  final RequestType? filterType;
  final RequestStatus? filterStatus;
  final String? filterTutor;
  final List<String> tutors;
  final ValueChanged<RequestType?> onTypeChanged;
  final ValueChanged<RequestStatus?> onStatusChanged;
  final ValueChanged<String?> onTutorChanged;

  const RequestFilterBar({
    super.key,
    required this.filterType,
    required this.filterStatus,
    required this.filterTutor,
    required this.tutors,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onTutorChanged,
  });

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
            icon: Icons.category_outlined,
            label: filterType == RequestType.demo
                ? 'Demo'
                : filterType == RequestType.paid
                    ? 'Paid'
                    : filterType == RequestType.paidDemo
                        ? 'Paid Demo'
                        : 'Type',
            active: filterType != null,
            onTap: () {
              if (filterType == null) {
                onTypeChanged(RequestType.demo);
              } else if (filterType == RequestType.demo) {
                onTypeChanged(RequestType.paid);
              } else if (filterType == RequestType.paid) {
                onTypeChanged(RequestType.paidDemo);
              } else {
                onTypeChanged(null);
              }
            },
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            icon: Icons.radio_button_checked_rounded,
            label: filterStatus == RequestStatus.pending
                ? 'Pending'
                : filterStatus == RequestStatus.accepted
                    ? 'Accepted'
                    : filterStatus == RequestStatus.rejected
                        ? 'Rejected'
                        : 'Status',
            active: filterStatus != null,
            onTap: () {
              if (filterStatus == null) {
                onStatusChanged(RequestStatus.pending);
              } else if (filterStatus == RequestStatus.pending) {
                onStatusChanged(RequestStatus.accepted);
              } else if (filterStatus == RequestStatus.accepted) {
                onStatusChanged(RequestStatus.rejected);
              } else {
                onStatusChanged(null);
              }
            },
          ),
          const SizedBox(width: 8),
          _DropdownChip(
            icon: Icons.person_outline_rounded,
            label: filterTutor ?? 'Tutor',
            active: filterTutor != null,
            items: tutors,
            value: filterTutor,
            onChanged: onTutorChanged,
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
