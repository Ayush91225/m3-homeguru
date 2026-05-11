import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'tutor_request_model.dart';
import '../../screens/shared/sessions_listing_screen.dart';

class TutorRequestTile extends StatelessWidget {
  final TutorBookingRequest request;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const TutorRequestTile({
    super.key,
    required this.request,
    this.onAccept,
    this.onDecline,
  });

  String _fmtDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final p = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day} ${months[d.month - 1]} ${d.year}  $h:$m $p';
  }

  void _showDetailsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RequestDetailsSheet(
        request: request,
        onAccept: onAccept,
        onDecline: onDecline,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        InkWell(
          onTap: () => _showDetailsSheet(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: cs.surfaceContainerHighest,
                  backgroundImage: request.studentImage.isNotEmpty
                      ? CachedNetworkImageProvider(request.studentImage)
                      : null,
                  child: request.studentImage.isEmpty
                      ? Icon(Icons.person, size: 24, color: cs.onSurfaceVariant)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              request.studentName,
                              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _fmtDate(request.requestedAt),
                            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            request.subject,
                            style: tt.labelSmall?.copyWith(
                              color: cs.tertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '  ·  ${request.level}',
                            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      _StatusTag(status: request.status),
                      const SizedBox(height: 5),
                      if (request.type == TutorRequestType.reschedule) ...[
                        _MetaItem(
                          icon: Icons.event_busy_rounded,
                          label: 'Original: ${_fmtDate(request.originalDate!)} ${request.originalTime}',
                        ),
                        _MetaItem(
                          icon: Icons.event_available_rounded,
                          label: 'New: ${_fmtDate(request.newDate!)} ${request.newTime}',
                          color: cs.tertiary,
                        ),
                      ] else ...[
                        if (request.preferredSlot != null)
                          _MetaItem(icon: Icons.access_time_rounded, label: request.preferredSlot!),
                        if (request.schedule != null)
                          _MetaItem(icon: Icons.calendar_today_rounded, label: request.schedule!),
                        if (request.totalSessions != null)
                          _MetaItem(icon: Icons.class_outlined, label: '${request.totalSessions} sessions'),
                        if (request.perHourRate != null)
                          _MetaItem(icon: Icons.currency_rupee_rounded, label: '₹${request.perHourRate}/hr'),
                      ],
                      if (request.status == TutorRequestStatus.pending && request.type != TutorRequestType.reschedule)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: onDecline,
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(36),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    side: BorderSide(color: cs.error),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  child: Text('Decline', style: TextStyle(color: cs.error, fontSize: 13)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton(
                                  onPressed: onAccept,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: cs.tertiary,
                                    minimumSize: const Size.fromHeight(36),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  child: const Text('Accept', style: TextStyle(fontSize: 13)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (request.status == TutorRequestStatus.pending && request.type == TutorRequestType.reschedule)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: onDecline,
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(36),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    side: BorderSide(color: cs.error),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  child: Text('Decline', style: TextStyle(color: cs.error, fontSize: 13)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton(
                                  onPressed: onAccept,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: cs.tertiary,
                                    minimumSize: const Size.fromHeight(36),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  child: const Text('Accept', style: TextStyle(fontSize: 13)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (request.status == TutorRequestStatus.accepted)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SessionsListingScreen(initialTutor: request.studentName, isTutor: true),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: cs.tertiaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.history_rounded, size: 12, color: cs.onTertiaryContainer),
                                  const SizedBox(width: 4),
                                  Text(
                                    'View Sessions',
                                    style: tt.labelSmall?.copyWith(
                                      color: cs.onTertiaryContainer,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          indent: 16 + 48 + 12,
          color: cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ],
    );
  }
}

class _StatusTag extends StatelessWidget {
  final TutorRequestStatus status;
  const _StatusTag({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (label, color, bg) = switch (status) {
      TutorRequestStatus.pending => ('Pending', cs.tertiary, cs.tertiaryContainer),
      TutorRequestStatus.accepted => ('Accepted', Colors.green.shade700, Colors.green.shade100.withValues(alpha: 1.0)),
      TutorRequestStatus.declined => ('Declined', cs.error, cs.errorContainer),
    };
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

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _MetaItem({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final itemColor = color ?? cs.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 13, color: itemColor),
          const SizedBox(width: 4),
          Expanded(
            child: Text(label, style: tt.labelSmall?.copyWith(color: itemColor)),
          ),
        ],
      ),
    );
  }
}

class _RequestDetailsSheet extends StatelessWidget {
  final TutorBookingRequest request;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const _RequestDetailsSheet({
    required this.request,
    this.onAccept,
    this.onDecline,
  });

  String _fmtDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: cs.surfaceContainerHighest,
                  backgroundImage: request.studentImage.isNotEmpty
                      ? CachedNetworkImageProvider(request.studentImage)
                      : null,
                  child: request.studentImage.isEmpty
                      ? Icon(Icons.person, size: 28, color: cs.onSurfaceVariant)
                      : null,
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
                        '${request.subject} · ${request.level}',
                        style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (request.type == TutorRequestType.reschedule) ...[
              Text('Reschedule Request', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
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
                                  Text(_fmtDate(request.originalDate!), style: tt.bodySmall),
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
                                  Text(_fmtDate(request.newDate!), style: tt.bodySmall?.copyWith(color: cs.tertiary, fontWeight: FontWeight.w600)),
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
                  ],
                ),
              ),
            ] else ...[
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
            if (request.status == TutorRequestStatus.pending) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onDecline?.call();
                      },
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
                      onPressed: () {
                        Navigator.pop(context);
                        onAccept?.call();
                      },
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
            ],
          ],
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
