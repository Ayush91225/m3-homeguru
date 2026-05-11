import 'package:flutter/material.dart';
import 'request_model.dart';
import '../../screens/shared/sessions_listing_screen.dart';
import '../schedule/payment_pending_sheet.dart';

class RequestTile extends StatelessWidget {
  final BookingRequest request;
  const RequestTile({super.key, required this.request});

  String _fmtDate(DateTime d) {
    final local = d.toLocal();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final m = local.minute.toString().padLeft(2, '0');
    final p = local.hour >= 12 ? 'PM' : 'AM';
    return '${local.day} ${months[local.month - 1]} ${local.year}, $h:$m $p';
  }

  void _showPaymentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => PaymentPendingSheet(
        tutorName: request.tutor,
        tutorImage: request.tutorImage,
        subject: request.subject,
        level: request.level,
        sessionsBooked: request.sessionsBooked ?? 1,
        preferredSlot: request.schedule ?? request.preferredSlot ?? '',
        perHourPrice: request.perHourPrice ?? 99,
        classesPerWeek: request.classesPerWeek ?? 1,
        durationMonths: request.durationMonths ?? 1,
        bookingAcceptedAt: request.bookingAcceptedAt ?? DateTime.now(),
      ),
    );
  }

  void _viewSessions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SessionsListingScreen(initialTutor: request.tutor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: cs.surfaceContainerHighest,
                backgroundImage: NetworkImage(request.tutorImage),
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
                            request.tutor,
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
                            color: cs.primary,
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
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _StatusTag(status: request.status),
                        _TypeTag(type: request.type),
                        if (request.status == RequestStatus.accepted)
                          if (request.isConfirmed)
                            _ConfirmedTag()
                          else
                            _PaymentPendingTag(),
                      ],
                    ),
                    const SizedBox(height: 5),
                    if (request.preferredSlot != null)
                      _MetaItem(icon: Icons.access_time_rounded, label: request.preferredSlot!),
                    if (request.schedule != null)
                      _MetaItem(icon: Icons.calendar_today_rounded, label: request.schedule!),
                    if (request.sessionsBooked != null)
                      _MetaItem(icon: Icons.class_outlined, label: '${request.sessionsBooked} sessions'),
                    if (request.perHourPrice != null)
                      _MetaItem(icon: Icons.currency_rupee_rounded, label: '₹${request.perHourPrice}/hr'),
                    if (request.respondedAt != null)
                      _MetaItem(
                        icon: Icons.check_circle_outline_rounded,
                        label: 'Responded ${_fmtDate(request.respondedAt!)}',
                      ),
                    if (request.rejectionReason != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 13, color: cs.error),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                request.rejectionReason!,
                                style: tt.labelSmall?.copyWith(color: cs.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (request.status == RequestStatus.accepted && !request.isConfirmed)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: GestureDetector(
                          onTap: () => _showPaymentSheet(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.payment_rounded, size: 12, color: cs.onPrimary),
                                const SizedBox(width: 4),
                                Text(
                                  'Pay Now',
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.onPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (request.isConfirmed)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: GestureDetector(
                          onTap: () => _viewSessions(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: cs.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.history_rounded, size: 12, color: cs.onSecondaryContainer),
                                const SizedBox(width: 4),
                                Text(
                                  'View Sessions',
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.onSecondaryContainer,
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
        Divider(
          height: 1,
          indent: 16 + 48 + 12,
          color: cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ],
    );
  }
}

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
  final RequestStatus status;
  const _StatusTag({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (label, color, bg) = switch (status) {
      RequestStatus.pending  => ('Pending', cs.tertiary, cs.tertiaryContainer),
      RequestStatus.accepted => ('Accepted', cs.primary, cs.primaryContainer),
      RequestStatus.rejected => ('Rejected', cs.error, cs.errorContainer),
    };
    return _MiniTag(label: label, color: color, bg: bg);
  }
}

class _TypeTag extends StatelessWidget {
  final RequestType type;
  const _TypeTag({required this.type});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = switch (type) {
      RequestType.demo     => 'Demo',
      RequestType.paid     => 'Paid',
      RequestType.paidDemo => 'Paid Demo',
    };
    return _MiniTag(
      label: label,
      color: cs.onSurfaceVariant,
      bg: cs.surfaceContainerLow,
    );
  }
}

class _PaymentPendingTag extends StatelessWidget {
  const _PaymentPendingTag();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _MiniTag(
      label: 'Payment Pending',
      color: cs.error,
      bg: cs.errorContainer.withValues(alpha: 0.5),
    );
  }
}

class _ConfirmedTag extends StatelessWidget {
  const _ConfirmedTag();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _MiniTag(
      label: 'Confirmed',
      color: cs.primary,
      bg: cs.primaryContainer.withValues(alpha: 0.5),
    );
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
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 13, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Expanded(
            child: Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}
