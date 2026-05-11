import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../schedule/payment_pending_sheet.dart';
import '../../../services/paid_payment_service.dart';

class PaymentBars extends StatefulWidget {
  const PaymentBars({super.key});

  @override
  State<PaymentBars> createState() => _PaymentBarsState();
}

class _PaymentBarsState extends State<PaymentBars> {
  Timer? _timer;
  List<Map<String, dynamic>> _pendingPayments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingPayments();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      _loadPendingPayments();
      setState(() {});
    });
  }

  Future<void> _loadPendingPayments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final learnerId = prefs.getString('userId');
      if (learnerId != null) {
        final payments = await PaidPaymentService.fetchPendingPayments(learnerId: learnerId);
        if (mounted) {
          setState(() {
            _pendingPayments = payments;
            _loading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading pending payments: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
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

  DateTime _getDeadline(Map<String, dynamic> payment) {
    final acceptedAt = payment['acceptedAt'] is String
        ? DateTime.tryParse(payment['acceptedAt']) ?? DateTime.now()
        : payment['acceptedAt'] as DateTime? ?? DateTime.now();
    return acceptedAt.add(const Duration(hours: 4));
  }

  String _formatPreferredSlot(Map<String, dynamic> payment) {
    final days = payment['preferredDays'] as List?;
    final time = payment['preferredTime']?.toString() ?? '17:00';
    if (days == null || days.isEmpty) return 'Schedule TBD';
    
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayLabels = days.map((d) => dayNames[(d as int) - 1]).join(', ');
    return '$dayLabels at $time';
  }

  void _showPaymentSheet(BuildContext context, Map<String, dynamic> payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => PaymentPendingSheet(
        requestId: payment['requestId']?.toString() ?? '',
        tutorName: payment['tutorName']?.toString() ?? 'Tutor',
        tutorImage: payment['tutorImage']?.toString() ?? '',
        subject: payment['subject']?.toString() ?? '',
        level: payment['level']?.toString() ?? '',
        sessionsBooked: payment['totalSessions'] as int? ?? 0,
        preferredSlot: _formatPreferredSlot(payment),
        perHourPrice: (payment['perHourRate'] as num?)?.toDouble() ?? 0,
        classesPerWeek: payment['classesPerWeek'] as int? ?? 0,
        durationMonths: payment['months'] as int? ?? 0,
        bookingAcceptedAt: _getDeadline(payment).subtract(const Duration(hours: 4)),
        onPaymentComplete: () {
          _loadPendingPayments();
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
      builder: (context) => _AllPaymentsSheet(
        payments: _pendingPayments,
        onPaymentComplete: _loadPendingPayments,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _pendingPayments.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (_pendingPayments.length == 1) {
      final payment = _pendingPayments[0];
      final deadline = _getDeadline(payment);
      final totalAmount = ((payment['perHourRate'] as num?)?.toDouble() ?? 0) * ((payment['totalSessions'] as int?) ?? 0);

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
      final aDeadline = _getDeadline(a);
      final bDeadline = _getDeadline(b);
      return aDeadline.isBefore(bDeadline) ? a : b;
    });
    final urgentDeadline = _getDeadline(mostUrgent);
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
                            Expanded(
                              child: Text(
                                '${_pendingPayments.length} payments pending',
                                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isUrgent) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cs.errorContainer,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  'urgent',
                                  style: tt.labelSmall?.copyWith(
                                    fontSize: 9,
                                    color: cs.onErrorContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
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
  }
}

class _AllPaymentsSheet extends StatefulWidget {
  final List<Map<String, dynamic>> payments;
  final VoidCallback onPaymentComplete;

  const _AllPaymentsSheet({
    required this.payments,
    required this.onPaymentComplete,
  });

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

  DateTime _getDeadline(Map<String, dynamic> payment) {
    final acceptedAt = payment['acceptedAt'] is String
        ? DateTime.tryParse(payment['acceptedAt']) ?? DateTime.now()
        : payment['acceptedAt'] as DateTime? ?? DateTime.now();
    return acceptedAt.add(const Duration(hours: 4));
  }

  String _formatPreferredSlot(Map<String, dynamic> payment) {
    final days = payment['preferredDays'] as List?;
    final time = payment['preferredTime']?.toString() ?? '17:00';
    if (days == null || days.isEmpty) return 'Schedule TBD';
    
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayLabels = days.map((d) => dayNames[(d as int) - 1]).join(', ');
    return '$dayLabels at $time';
  }

  void _showPaymentSheet(Map<String, dynamic> payment) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => PaymentPendingSheet(
        requestId: payment['requestId']?.toString() ?? '',
        tutorName: payment['tutorName']?.toString() ?? 'Tutor',
        tutorImage: payment['tutorImage']?.toString() ?? '',
        subject: payment['subject']?.toString() ?? '',
        level: payment['level']?.toString() ?? '',
        sessionsBooked: payment['totalSessions'] as int? ?? 0,
        preferredSlot: _formatPreferredSlot(payment),
        perHourPrice: (payment['perHourRate'] as num?)?.toDouble() ?? 0,
        classesPerWeek: payment['classesPerWeek'] as int? ?? 0,
        durationMonths: payment['months'] as int? ?? 0,
        bookingAcceptedAt: _getDeadline(payment).subtract(const Duration(hours: 4)),
        onPaymentComplete: widget.onPaymentComplete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final sortedPayments = List<Map<String, dynamic>>.from(widget.payments)
      ..sort((a, b) {
        final aDeadline = _getDeadline(a);
        final bDeadline = _getDeadline(b);
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
                  final deadline = _getDeadline(payment);
                  final totalAmount = ((payment['perHourRate'] as num?)?.toDouble() ?? 0) * ((payment['totalSessions'] as int?) ?? 0);
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
