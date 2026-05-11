import 'package:flutter/material.dart';
import '../../../screens/dashboard/tutor/tutor_dashboard.dart';
import '../../../services/tutor_data_model.dart';

class TutorPendingRequests extends StatelessWidget {
  const TutorPendingRequests({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final data = TutorData.of(context);
    final pending = data.pendingRequests;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Icon(Icons.inbox_rounded, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text('Pending Requests', style: tt.bodyMedium?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w400)),
              const Spacer(),
              TextButton(
                onPressed: () {
                  final s = context.findAncestorStateOfType<TutorDashboardState>();
                  s?.onItemTapped(1);
                },
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: Text('View All', style: tt.labelMedium?.copyWith(color: cs.tertiary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        if (pending.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Column(children: [
              Icon(Icons.inbox_outlined, size: 36, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
              const SizedBox(height: 8),
              Text('No pending requests', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ]),
          )
        else
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: pending.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final req = pending[i];
                return Container(
                  width: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(req['studentName'] ?? '', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(req['subject'] ?? '', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: cs.tertiaryContainer, borderRadius: BorderRadius.circular(99)),
                      child: Text(req['type'] ?? 'Request', style: tt.labelSmall?.copyWith(color: cs.onTertiaryContainer, fontWeight: FontWeight.w600, fontSize: 10)),
                    ),
                  ]),
                );
              },
            ),
          ),
      ],
    );
  }
}
