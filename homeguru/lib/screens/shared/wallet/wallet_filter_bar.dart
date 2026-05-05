import 'package:flutter/material.dart';
import 'wallet_models.dart';

class WalletFilters {
  final DateTimeRange? dateRange;
  final String? tutor;
  final TxType? type;

  const WalletFilters({this.dateRange, this.tutor, this.type});

  bool get hasAny => dateRange != null || tutor != null || type != null;

  WalletFilters copyWith({
    Object? dateRange = _sentinel,
    Object? tutor = _sentinel,
    Object? type = _sentinel,
  }) =>
      WalletFilters(
        dateRange: dateRange == _sentinel ? this.dateRange : dateRange as DateTimeRange?,
        tutor:     tutor     == _sentinel ? this.tutor     : tutor as String?,
        type:      type      == _sentinel ? this.type      : type as TxType?,
      );

  List<WalletTx> apply(List<WalletTx> txs) {
    return txs.where((tx) {
      if (type != null && tx.type != type) return false;
      if (tutor != null && tx.tutorName != tutor) return false;
      if (dateRange != null) {
        final d = tx.date;
        if (d.isBefore(dateRange!.start) || d.isAfter(dateRange!.end)) return false;
      }
      return true;
    }).toList();
  }
}

const _sentinel = Object();

class WalletFilterBar extends StatelessWidget {
  final WalletFilters filters;
  final List<String> tutors;
  final ValueChanged<WalletFilters> onChanged;

  const WalletFilterBar({
    super.key,
    required this.filters,
    required this.tutors,
    required this.onChanged,
  });

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: now,
      initialDateRange: filters.dateRange,
      builder: (context, child) => Theme(
        data: Theme.of(context),
        child: child!,
      ),
    );
    if (picked != null) onChanged(filters.copyWith(dateRange: picked));
  }

  String _dateLabel(DateTimeRange r) {
    String fmt(DateTime d) => '${d.day}/${d.month}';
    return '${fmt(r.start)} – ${fmt(r.end)}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Date range
          _FilterChip(
            label: filters.dateRange != null ? _dateLabel(filters.dateRange!) : 'Date range',
            icon: Icons.date_range_outlined,
            active: filters.dateRange != null,
            cs: cs,
            tt: tt,
            onTap: () => _pickDateRange(context),
            onClear: filters.dateRange != null ? () => onChanged(filters.copyWith(dateRange: null)) : null,
          ),
          const SizedBox(width: 8),
          // Tutor
          _TutorChip(
            tutors: tutors,
            selected: filters.tutor,
            cs: cs,
            tt: tt,
            onSelected: (t) => onChanged(filters.copyWith(tutor: t)),
            onClear: filters.tutor != null ? () => onChanged(filters.copyWith(tutor: null)) : null,
          ),
          const SizedBox(width: 8),
          // Type chips
          ...TxType.values.map((t) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: t.label,
                  icon: t.icon,
                  active: filters.type == t,
                  cs: cs,
                  tt: tt,
                  onTap: () => onChanged(filters.copyWith(type: filters.type == t ? null : t)),
                  onClear: null,
                ),
              )),
          // Clear all
          if (filters.hasAny)
            _FilterChip(
              label: 'Clear all',
              icon: Icons.close_rounded,
              active: false,
              cs: cs,
              tt: tt,
              onTap: () => onChanged(const WalletFilters()),
              onClear: null,
              isDestructive: true,
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final ColorScheme cs;
  final TextTheme tt;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final bool isDestructive;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.cs,
    required this.tt,
    required this.onTap,
    required this.onClear,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDestructive
        ? cs.errorContainer.withValues(alpha: 0.5)
        : active
            ? cs.primaryContainer
            : cs.surfaceContainerHighest;
    final fg = isDestructive
        ? cs.error
        : active
            ? cs.onPrimaryContainer
            : cs.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: active ? Border.all(color: cs.primary.withValues(alpha: 0.4)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
            Text(label, style: tt.labelSmall?.copyWith(color: fg, fontWeight: active ? FontWeight.w600 : FontWeight.w500)),
            if (onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded, size: 13, color: fg),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TutorChip extends StatelessWidget {
  final List<String> tutors;
  final String? selected;
  final ColorScheme cs;
  final TextTheme tt;
  final ValueChanged<String?> onSelected;
  final VoidCallback? onClear;

  const _TutorChip({
    required this.tutors,
    required this.selected,
    required this.cs,
    required this.tt,
    required this.onSelected,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final active = selected != null;
    final bg = active ? cs.primaryContainer : cs.surfaceContainerHighest;
    final fg = active ? cs.onPrimaryContainer : cs.onSurfaceVariant;

    return GestureDetector(
      onTap: () async {
        final picked = await showModalBottomSheet<String>(
          context: context,
          builder: (ctx) => _TutorPicker(tutors: tutors, selected: selected, cs: cs, tt: tt),
        );
        if (picked != null) onSelected(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: active ? Border.all(color: cs.primary.withValues(alpha: 0.4)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_outline_rounded, size: 14, color: fg),
            const SizedBox(width: 6),
            Text(
              selected ?? 'Tutor',
              style: tt.labelSmall?.copyWith(color: fg, fontWeight: active ? FontWeight.w600 : FontWeight.w500),
            ),
            const SizedBox(width: 4),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded, size: 13, color: fg),
              )
            else
              Icon(Icons.expand_more_rounded, size: 14, color: fg),
          ],
        ),
      ),
    );
  }
}

class _TutorPicker extends StatelessWidget {
  final List<String> tutors;
  final String? selected;
  final ColorScheme cs;
  final TextTheme tt;

  const _TutorPicker({required this.tutors, required this.selected, required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text('Select Tutor', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
          ...tutors.map((t) => ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: cs.primaryContainer,
                  child: Text(t[0], style: tt.labelMedium?.copyWith(color: cs.onPrimaryContainer)),
                ),
                title: Text(t, style: tt.bodyMedium),
                trailing: selected == t ? Icon(Icons.check_rounded, color: cs.primary) : null,
                onTap: () => Navigator.pop(context, t),
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
