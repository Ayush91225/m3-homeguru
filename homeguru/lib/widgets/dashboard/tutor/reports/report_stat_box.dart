import 'package:flutter/material.dart';

class ReportStatBox extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  final bool highlight;
  final ColorScheme cs;
  final TextTheme tt;

  const ReportStatBox({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    required this.icon,
    this.highlight = false,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: highlight ? cs.tertiary.withValues(alpha: 0.5) : cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: cs.tertiary),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.w400,
              color: highlight ? cs.tertiary : cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: tt.labelSmall?.copyWith(
                color: cs.tertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
