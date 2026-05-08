import 'package:flutter/material.dart';

class ReportFilters extends StatelessWidget {
  final ColorScheme cs;
  final TextTheme tt;
  final String? selectedStudent;
  final DateTimeRange? dateRange;
  final VoidCallback onStudentFilterTap;
  final VoidCallback onDateFilterTap;
  final VoidCallback? onClearFilters;
  final List<String>? studentsList;
  final bool showStudentFilter;

  const ReportFilters({
    super.key,
    required this.cs,
    required this.tt,
    this.selectedStudent,
    this.dateRange,
    required this.onStudentFilterTap,
    required this.onDateFilterTap,
    this.onClearFilters,
    this.studentsList,
    this.showStudentFilter = true,
  });

  String _formatDateRange(DateTimeRange range) {
    final start = '${range.start.day}/${range.start.month}';
    final end = '${range.end.day}/${range.end.month}';
    return '$start - $end';
  }

  @override
  Widget build(BuildContext context) {
    final hasFilters = selectedStudent != null || dateRange != null;

    return Column(
      children: [
        Row(
          children: [
            if (showStudentFilter) ...[
              Expanded(
                child: _FilterButton(
                  label: dateRange != null ? _formatDateRange(dateRange!) : 'Date Range',
                  icon: Icons.calendar_today_rounded,
                  isActive: dateRange != null,
                  onTap: onDateFilterTap,
                  cs: cs,
                  tt: tt,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FilterButton(
                  label: selectedStudent ?? 'All Students',
                  icon: Icons.person_rounded,
                  isActive: selectedStudent != null,
                  onTap: onStudentFilterTap,
                  cs: cs,
                  tt: tt,
                ),
              ),
            ] else
              Expanded(
                child: _FilterButton(
                  label: dateRange != null ? _formatDateRange(dateRange!) : 'Date Range',
                  icon: Icons.calendar_today_rounded,
                  isActive: dateRange != null,
                  onTap: onDateFilterTap,
                  cs: cs,
                  tt: tt,
                ),
              ),
          ],
        ),
        if (hasFilters) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.filter_alt_rounded, size: 14, color: cs.tertiary),
              const SizedBox(width: 6),
              Text(
                'Filters active',
                style: tt.labelSmall?.copyWith(
                  color: cs.tertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onClearFilters,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Clear',
                  style: tt.labelSmall?.copyWith(
                    color: cs.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final ColorScheme cs;
  final TextTheme tt;

  const _FilterButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: isActive ? cs.tertiaryContainer : cs.surfaceContainerHighest,
                foregroundColor: isActive ? cs.onTertiaryContainer : cs.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(999),
                    bottomLeft: Radius.circular(999),
                  ),
                ),
                minimumSize: const Size(0, 36),
                maximumSize: const Size(double.infinity, 36),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isActive ? cs.onTertiaryContainer : cs.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: isActive ? cs.onTertiaryContainer.withValues(alpha: 0.2) : cs.onSurfaceVariant.withValues(alpha: 0.2),
          ),
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(999),
              bottomRight: Radius.circular(999),
            ),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isActive ? cs.tertiaryContainer : cs.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(999),
                  bottomRight: Radius.circular(999),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 16,
                  color: isActive ? cs.onTertiaryContainer : cs.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
