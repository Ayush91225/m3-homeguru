import 'package:flutter/material.dart';
import 'dart:async';
import '../../schedule/payment_pending_sheet.dart';

// Global list that can be modified
final List<Map<String, dynamic>> _pendingPayments = [
  {
    'tutorName': 'Priya Sharma',
    'tutorImage': 'https://i.pravatar.cc/150?img=5',
    'subject': 'Mathematics',
    'level': 'Grade 10 CBSE',
    'sessionsBooked': 20,
    'preferredSlot': 'Mon, Wed, Fri at 5:00 PM',
    'perHourPrice': 499.0,
    'classesPerWeek': 3,
    'durationMonths': 2,
    'bookingAcceptedAt': DateTime.now().subtract(const Duration(hours: 2, minutes: 19)),
  },
  {
    'tutorName': 'Rahul Verma',
    'tutorImage': 'https://i.pravatar.cc/150?img=12',
    'subject': 'Physics',
    'level': 'Grade 11 CBSE',
    'sessionsBooked': 15,
    'preferredSlot': 'Tue, Thu at 6:00 PM',
    'perHourPrice': 599.0,
    'classesPerWeek': 2,
    'durationMonths': 2,
    'bookingAcceptedAt': DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
  },
  {
    'tutorName': 'Anjali Patel',
    'tutorImage': 'https://i.pravatar.cc/150?img=9',
    'subject': 'Chemistry',
    'level': 'Grade 12 CBSE',
    'sessionsBooked': 12,
    'preferredSlot': 'Mon, Wed at 4:00 PM',
    'perHourPrice': 549.0,
    'classesPerWeek': 2,
    'durationMonths': 2,
    'bookingAcceptedAt': DateTime.now().subtract(const Duration(hours: 3, minutes: 45)),
  },
];

// Notifier to trigger rebuilds
final ValueNotifier<int> _paymentUpdateNotifier = ValueNotifier<int>(0);

class PaymentBars extends StatefulWidget {
  const PaymentBars({super.key});

  @override
  State<PaymentBars> createState() => _PaymentBarsState();
}

class _PaymentBarsState extends State<PaymentBars> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTimeRemaining(DateTime deadline) {
    final remaining = deadline.difference(DateTime.now());
    if (remaining.isNegative) return 'Expired';
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} remaining';
  }

  void _showPaymentSheet(BuildContext context, Map<String, dynamic> payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => PaymentPendingSheet(
        tutorName: payment['tutorName'],
        tutorImage: payment['tutorImage'],
        subject: payment['subject'],
        level: payment['level'],
        sessionsBooked: payment['sessionsBooked'],
        preferredSlot: payment['preferredSlot'],
        perHourPrice: payment['perHourPrice'],
        classesPerWeek: payment['classesPerWeek'],
        durationMonths: payment['durationMonths'],
        bookingAcceptedAt: payment['bookingAcceptedAt'],
        onPaymentComplete: () {
          _pendingPayments.removeWhere((p) => 
            p['tutorName'] == payment['tutorName'] && 
            p['subject'] == payment['subject']
          );
          _paymentUpdateNotifier.value++;
        },
      ),
    );
  }

  void _showAllPayments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => _AllPaymentsSheet(payments: _pendingPayments),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _paymentUpdateNotifier,
      builder: (context, _, __) {
        if (_pendingPayments.isEmpty) return const SizedBox.shrink();

        final cs = Theme.of(context).colorScheme;
        final tt = Theme.of(context).textTheme;

        if (_pendingPayments.length == 1) {
          final payment = _pendingPayments[0];
          final deadline = (payment['bookingAcceptedAt'] as DateTime).add(const Duration(hours: 4));
          final totalAmount = (payment['perHourPrice'] as double) * (payment['sessionsBooked'] as int);

      return Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5), width: 0.5),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.credit_card_rounded, size: 16, color: cs.onSurfaceVariant),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${payment['subject']} · ₹${totalAmount.toStringAsFixed(0)}',
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTimeRemaining(deadline),
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            FilledButton(
              onPressed: () => _showPaymentSheet(context, payment),
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Pay now', style: tt.labelMedium?.copyWith(fontSize: 12, color: cs.onPrimary)),
            ),
          ],
        ),
      );
    }

    // Multiple payments - stacked cards
    final mostUrgent = _pendingPayments.reduce((a, b) {
      final aDeadline = (a['bookingAcceptedAt'] as DateTime).add(const Duration(hours: 4));
      final bDeadline = (b['bookingAcceptedAt'] as DateTime).add(const Duration(hours: 4));
      return aDeadline.isBefore(bDeadline) ? a : b;
    });
    final urgentDeadline = (mostUrgent['bookingAcceptedAt'] as DateTime).add(const Duration(hours: 4));
    final timeLeft = _formatTimeRemaining(urgentDeadline);
    final isUrgent = urgentDeadline.difference(DateTime.now()).inHours < 12;

    return SizedBox(
      height: 68,
      child: Stack(
        children: [
          // Background stacked cards
          if (_pendingPayments.length > 2)
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3), width: 0.5),
                ),
              ),
            ),
          if (_pendingPayments.length > 1)
            Positioned(
              top: 4,
              left: 4,
              right: 4,
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4), width: 0.5),
                ),
              ),
            ),
          // Front card
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outline.withValues(alpha: 0.5), width: 0.5),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isUrgent ? cs.errorContainer : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.warning_rounded,
                      size: 16,
                      color: isUrgent ? cs.onErrorContainer : cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${_pendingPayments.length} payments pending',
                                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isUrgent)
                              const SizedBox(width: 8),
                            if (isUrgent)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cs.errorContainer,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  'urgent',
                                  style: tt.labelSmall?.copyWith(
                                    fontSize: 10,
                                    color: cs.onErrorContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${mostUrgent['subject']} · $timeLeft (most urgent)',
                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  FilledButton(
                    onPressed: () => _showAllPayments(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('View all', style: tt.labelMedium?.copyWith(fontSize: 12, color: cs.onPrimary)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}

class _AllPaymentsSheet extends StatefulWidget {
  final List<Map<String, dynamic>> payments;

  const _AllPaymentsSheet({required this.payments});

  @override
  State<_AllPaymentsSheet> createState() => _AllPaymentsSheetState();
}

class _AllPaymentsSheetState extends State<_AllPaymentsSheet> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTimeRemaining(DateTime deadline) {
    final remaining = deadline.difference(DateTime.now());
    if (remaining.isNegative) return 'Expired';
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} left';
  }

  void _showPaymentSheet(Map<String, dynamic> payment) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => PaymentPendingSheet(
        tutorName: payment['tutorName'],
        tutorImage: payment['tutorImage'],
        subject: payment['subject'],
        level: payment['level'],
        sessionsBooked: payment['sessionsBooked'],
        preferredSlot: payment['preferredSlot'],
        perHourPrice: payment['perHourPrice'],
        classesPerWeek: payment['classesPerWeek'],
        durationMonths: payment['durationMonths'],
        bookingAcceptedAt: payment['bookingAcceptedAt'],
        onPaymentComplete: () {
          _pendingPayments.removeWhere((p) => 
            p['tutorName'] == payment['tutorName'] && 
            p['subject'] == payment['subject']
          );
          _paymentUpdateNotifier.value++;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final sortedPayments = List<Map<String, dynamic>>.from(widget.payments)
      ..sort((a, b) {
        final aDeadline = (a['bookingAcceptedAt'] as DateTime).add(const Duration(hours: 4));
        final bDeadline = (b['bookingAcceptedAt'] as DateTime).add(const Duration(hours: 4));
        return aDeadline.compareTo(bDeadline);
      });

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pending Payments',
                      style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: cs.onSurfaceVariant),
                    style: IconButton.styleFrom(
                      backgroundColor: cs.surfaceContainerHighest,
                      minimumSize: const Size(40, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                itemCount: sortedPayments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final payment = sortedPayments[index];
                  final deadline = (payment['bookingAcceptedAt'] as DateTime).add(const Duration(hours: 4));
                  final totalAmount = (payment['perHourPrice'] as double) * (payment['sessionsBooked'] as int);
                  final isUrgent = deadline.difference(DateTime.now()).inHours < 12;

                  return Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isUrgent ? cs.error.withValues(alpha: 0.3) : cs.outlineVariant.withValues(alpha: 0.5),
                        width: 0.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isUrgent ? cs.errorContainer : cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.credit_card_rounded,
                            size: 16,
                            color: isUrgent ? cs.onErrorContainer : cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      '${payment['subject']} · ₹${totalAmount.toStringAsFixed(0)}',
                                      style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isUrgent)
                                    const SizedBox(width: 8),
                                  if (isUrgent)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: cs.errorContainer,
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: Text(
                                        'urgent',
                                        style: tt.labelSmall?.copyWith(
                                          fontSize: 10,
                                          color: cs.onErrorContainer,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${payment['tutorName']} · ${_formatTimeRemaining(deadline)}',
                                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        FilledButton(
                          onPressed: () => _showPaymentSheet(payment),
                          style: FilledButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Pay now', style: tt.labelMedium?.copyWith(fontSize: 12, color: cs.onPrimary)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
