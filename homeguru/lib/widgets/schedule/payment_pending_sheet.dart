import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/razorpay_service.dart';
import '../../services/user_profile_store.dart';
import '../../services/paid_payment_service.dart';

class PaymentPendingSheet extends StatefulWidget {
  final String requestId;
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
    required this.requestId,
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

  @override
  State<PaymentPendingSheet> createState() => _PaymentPendingSheetState();
}

class _PaymentPendingSheetState extends State<PaymentPendingSheet> {
  final RazorpayService _razorpayService = RazorpayService();
  bool _isProcessing = false;
  String? _pendingOrderId;

  @override
  void initState() {
    super.initState();
    _razorpayService.initialize(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentFailure,
      onExternalWallet: _handleExternalWallet,
    );
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // Verify payment and create sessions
      await PaidPaymentService.verifyPayment(
        requestId: widget.requestId,
        orderId: _pendingOrderId ?? '',
        paymentId: response.paymentId ?? '',
        signature: response.signature ?? '',
      );

      if (mounted) {
        setState(() => _isProcessing = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment successful! ${widget.sessionsBooked} sessions created.'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onPaymentComplete?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment verification failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handlePaymentFailure(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${response.message}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _isProcessing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('External wallet: ${response.walletName}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      // Create order via API
      final orderData = await PaidPaymentService.createOrder(requestId: widget.requestId);
      final orderId = orderData['orderId'];
      _pendingOrderId = orderId;

      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('profile_name') ?? 'Student';
      final userEmail = prefs.getString('profile_email') ?? '';
      final userPhone = prefs.getString('profile_phone') ?? '';

      final amountInPaise = orderData['amount'] as int;

      _razorpayService.openCheckout(
        orderId: orderId,
        amount: amountInPaise,
        name: userName,
        email: userEmail,
        contact: userPhone,
        description: '${widget.sessionsBooked} sessions with ${widget.tutorName}',
        notes: {
          'requestId': widget.requestId,
          'subject': widget.subject,
          'level': widget.level,
          'sessions': widget.sessionsBooked,
          'tutor': widget.tutorName,
        },
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create order: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  double get totalPrice => widget.sessionsBooked * widget.perHourPrice;

  Duration get timeRemaining {
    final deadline = widget.bookingAcceptedAt.add(const Duration(hours: 4));
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
                  backgroundImage: CachedNetworkImageProvider(widget.tutorImage),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.tutorName,
                        style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        widget.subject,
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
                    value: widget.subject,
                    cs: cs,
                    tt: tt,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Level',
                    value: widget.level,
                    cs: cs,
                    tt: tt,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Sessions Booked',
                    value: '${widget.sessionsBooked} sessions',
                    cs: cs,
                    tt: tt,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Preferred Slot',
                    value: widget.preferredSlot,
                    cs: cs,
                    tt: tt,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Per Hour Price',
                    value: '₹${widget.perHourPrice.toStringAsFixed(0)}',
                    cs: cs,
                    tt: tt,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Classes per Week',
                    value: '${widget.classesPerWeek} classes',
                    cs: cs,
                    tt: tt,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Duration',
                    value: '${widget.durationMonths} ${widget.durationMonths == 1 ? 'month' : 'months'}',
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
                    onPressed: _isProcessing ? null : _processPayment,
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: _isProcessing
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.onPrimary,
                            ),
                          )
                        : const Text('Pay Now'),
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
