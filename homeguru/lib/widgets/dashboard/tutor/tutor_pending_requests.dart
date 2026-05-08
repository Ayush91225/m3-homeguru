import 'package:flutter/material.dart';
import '../../../screens/dashboard/tutor/tutor_dashboard.dart';
import '../../requests/tutor_request_model.dart';
import '../../requests/mock_tutor_requests.dart';

class TutorPendingRequests extends StatelessWidget {
  const TutorPendingRequests({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final allRequests = [...mockTutorRequests, ...mockRescheduleRequests];
    final pendingPaid = allRequests.where((r) => r.status == TutorRequestStatus.pending && r.type == TutorRequestType.paid).take(3).toList();
    final pendingDemo = allRequests.where((r) => r.status == TutorRequestStatus.pending && r.type == TutorRequestType.demo).take(3).toList();
    final pendingReschedule = allRequests.where((r) => r.status == TutorRequestStatus.pending && r.type == TutorRequestType.reschedule).take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Icon(Icons.inbox_rounded, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Pending Requests',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  final s = context.findAncestorStateOfType<TutorDashboardState>();
                  s?.onItemTapped(1);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View All',
                  style: tt.labelMedium?.copyWith(
                    color: cs.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            children: [
              ...pendingPaid.map((req) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _RequestCard(
                  request: req,
                  typeLabel: 'Paid Class',
                  typeIcon: Icons.payments_rounded,
                  color: cs.tertiary,
                  backgroundColor: cs.tertiaryContainer,
                ),
              )),
              ...pendingDemo.map((req) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _RequestCard(
                  request: req,
                  typeLabel: 'Demo Class',
                  typeIcon: Icons.school_rounded,
                  color: cs.primary,
                  backgroundColor: cs.primaryContainer,
                ),
              )),
              ...pendingReschedule.map((req) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _RequestCard(
                  request: req,
                  typeLabel: 'Reschedule',
                  typeIcon: Icons.schedule_rounded,
                  color: cs.secondary,
                  backgroundColor: cs.secondaryContainer,
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  final TutorBookingRequest request;
  final String typeLabel;
  final IconData typeIcon;
  final Color color;
  final Color backgroundColor;

  const _RequestCard({
    required this.request,
    required this.typeLabel,
    required this.typeIcon,
    required this.color,
    required this.backgroundColor,
  });

  String _fmtDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]}';
  }

  String _getTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => _showRequestSheet(context),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(typeIcon, size: 11, color: color),
                      const SizedBox(width: 4),
                      Text(
                        typeLabel,
                        style: tt.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(request.studentImage),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.studentName,
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        request.subject,
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (request.type == TutorRequestType.reschedule)
              Row(
                children: [
                  Icon(Icons.event_available_rounded, size: 12, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${_fmtDate(request.newDate!)} ${request.newTime}',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            else if (request.inHandAmount != null)
              Row(
                children: [
                  Icon(Icons.currency_rupee_rounded, size: 12, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '₹${request.inHandAmount!.toStringAsFixed(0)}',
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    ' in-hand',
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Text(
              _getTimeAgo(request.requestedAt),
              style: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestSheet(BuildContext context) {
    if (request.type == TutorRequestType.reschedule) {
      _showRescheduleSheet(context);
    } else {
      _showClassRequestSheet(context);
    }
  }

  void _showRescheduleSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(request.studentImage),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.studentName,
                        style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${request.subject} • ${request.level}',
                        style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Reschedule Request', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 14, color: cs.onSurface),
                            const SizedBox(width: 6),
                            Text(_fmtDateFull(request.originalDate!), style: tt.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 14, color: cs.onSurface),
                            const SizedBox(width: 6),
                            Text(request.originalTime!, style: tt.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: cs.tertiary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Requested', style: tt.labelSmall?.copyWith(color: cs.tertiary, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 14, color: cs.tertiary),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _fmtDateFull(request.newDate!),
                                style: tt.bodySmall?.copyWith(color: cs.tertiary, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 14, color: cs.tertiary),
                            const SizedBox(width: 6),
                            Text(request.newTime!, style: tt.bodySmall?.copyWith(color: cs.tertiary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (request.note != null) ...[
              const SizedBox(height: 16),
              Text('Note from Student', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(request.note!, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      side: BorderSide(color: cs.error),
                    ),
                    child: Text('Decline', style: TextStyle(color: cs.error)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.tertiary,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  void _showClassRequestSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(request.studentImage),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.studentName,
                          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${request.subject} • ${request.level}',
                          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      typeLabel,
                      style: tt.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Booking Details', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              if (request.preferredSlot != null)
                _DetailRow(icon: Icons.access_time_rounded, label: 'Preferred Slot', value: request.preferredSlot!),
              if (request.schedule != null)
                _DetailRow(icon: Icons.calendar_today_rounded, label: 'Schedule', value: request.schedule!),
              if (request.totalSessions != null)
                _DetailRow(icon: Icons.class_outlined, label: 'Total Sessions', value: '${request.totalSessions} sessions'),
              if (request.classesPerWeek != null)
                _DetailRow(icon: Icons.event_repeat_rounded, label: 'Classes Per Week', value: '${request.classesPerWeek} classes'),
              if (request.perHourRate != null)
                _DetailRow(icon: Icons.currency_rupee_rounded, label: 'Per Hour Rate', value: '₹${request.perHourRate}'),
              if (request.totalPrice != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Booking Price', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                          Text('₹${request.totalPrice!.toStringAsFixed(0)}', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Platform Fee (25%)', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                          Text('- ₹${((request.totalPrice! * 0.25)).toStringAsFixed(0)}', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                      Divider(height: 16, color: cs.outlineVariant),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('In-Hand Amount', style: tt.titleSmall?.copyWith(color: cs.tertiary, fontWeight: FontWeight.w600)),
                          Text('₹${request.inHandAmount!.toStringAsFixed(0)}', style: tt.titleMedium?.copyWith(color: cs.tertiary, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              if (request.note != null) ...[
                const SizedBox(height: 16),
                Text('Note from Student', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(request.note!, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        side: BorderSide(color: cs.error),
                      ),
                      child: Text('Decline', style: TextStyle(color: cs.error)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.tertiary,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtDateFull(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]}, ${d.year}';
  }
}

class _ViewAllCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ViewAllCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_forward_rounded,
                size: 32,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                'View All',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                Text(value, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
