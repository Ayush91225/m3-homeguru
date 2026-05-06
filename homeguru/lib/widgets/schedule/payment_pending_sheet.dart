import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PaymentPendingSheet extends StatelessWidget {
  final String tutorName;
  final String tutorImage;
  final String subject;
  final String level;
  final int sessionsBooked;
  final String preferredSlot;
  final double perHourPrice;
  final int classesPerWeek;
  final int durationMonths;
  final DateTime bookingAcceptedAt;
  final VoidCallback? onPaymentComplete;

  const PaymentPendingSheet({
    super.key,
    required this.tutorName,
    required this.tutorImage,
    required this.subject,
    required this.level,
    required this.sessionsBooked,
    required this.preferredSlot,
    required this.perHourPrice,
    required this.classesPerWeek,
    required this.durationMonths,
    required this.bookingAcceptedAt,
    this.onPaymentComplete,
  });

  double get totalPrice => sessionsBooked * perHourPrice;

  Duration get timeRemaining {
    final deadline = bookingAcceptedAt.add(const Duration(hours: 4));
    return deadline.difference(DateTime.now());
  }

  String get timeRemainingText {
    final remaining = timeRemaining;
    if (remaining.isNegative) return 'Expired';
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                Icon(Icons.payment_rounded, color: cs.primary),
                const SizedBox(width: 12),
                Text('Payment Pending', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 24),
            
            // Warning banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.error.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 20, color: cs.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete payment within ${timeRemainingText}',
                          style: tt.bodyMedium?.copyWith(
                            color: cs.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Booking will be cancelled if not paid within 4 hours',
                          style: tt.bodySmall?.copyWith(color: cs.onSurface),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tutor info
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: CachedNetworkImageProvider(tutorImage),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tutorName,
                        style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        subject,
                        style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Booking details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Subject',
                    value: subject,
                    cs: cs,
                    tt: tt,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Level',
                    value: level,
                    cs: cs,
                    tt: tt,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Sessions Booked',
                    value: '$sessionsBooked sessions',
                    cs: cs,
                    tt: tt,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Preferred Slot',
                    value: preferredSlot,
                    cs: cs,
                    tt: tt,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Per Hour Price',
                    value: '₹${perHourPrice.toStringAsFixed(0)}',
                    cs: cs,
                    tt: tt,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Classes per Week',
                    value: '$classesPerWeek classes',
                    cs: cs,
                    tt: tt,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Duration',
                    value: '$durationMonths ${durationMonths == 1 ? 'month' : 'months'}',
                    cs: cs,
                    tt: tt,
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    label: 'Total Amount',
                    value: '₹${totalPrice.toStringAsFixed(0)}',
                    cs: cs,
                    tt: tt,
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info about escrow
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 20, color: cs.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Amount will be held in Escrow Wallet. Tutor gets paid after each completed session.',
                      style: tt.bodySmall?.copyWith(color: cs.onSurface),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reminder set. We\'ll notify you later.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('Remind Later'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onPaymentComplete?.call();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Payment successful! ₹${totalPrice.toStringAsFixed(0)} paid.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('Pay Now'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme cs;
  final TextTheme tt;
  final bool isTotal;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.cs,
    required this.tt,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: tt.bodyMedium?.copyWith(
            color: isTotal ? cs.onSurface : cs.onSurfaceVariant,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: tt.bodyMedium?.copyWith(
            color: isTotal ? cs.primary : cs.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: isTotal ? 16 : null,
          ),
        ),
      ],
    );
  }
}
