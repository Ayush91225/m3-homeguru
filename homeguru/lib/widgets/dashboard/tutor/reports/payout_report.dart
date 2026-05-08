import 'package:flutter/material.dart';
import 'report_filters.dart';

class PayoutReport extends StatefulWidget {
  final ColorScheme cs;
  final TextTheme tt;

  const PayoutReport({super.key, required this.cs, required this.tt});

  @override
  State<PayoutReport> createState() => _PayoutReportState();
}

class _PayoutReportState extends State<PayoutReport> {
  String? _selectedStudent;
  DateTimeRange? _dateRange;

  final List<String> _students = ['Aarav Kumar', 'Diya Sharma', 'Arjun Patel'];

  final List<Map<String, dynamic>> _bookings = [
    {
      'student': 'Aarav Kumar',
      'subject': 'JEE Maths',
      'totalSessions': 20,
      'completed': 18,
      'missedByTutor': 1,
      'missedByLearner': 1,
      'ratePerHour': 400,
      'totalBooking': 8000,
      'inHandBooking': 6000,
      'credited': 5400,
      'pending': 600,
    },
    {
      'student': 'Diya Sharma',
      'subject': 'Chemistry',
      'totalSessions': 15,
      'completed': 14,
      'missedByTutor': 0,
      'missedByLearner': 1,
      'ratePerHour': 380,
      'totalBooking': 5700,
      'inHandBooking': 4275,
      'credited': 3990,
      'pending': 285,
    },
    {
      'student': 'Arjun Patel',
      'subject': 'Physics',
      'totalSessions': 12,
      'completed': 10,
      'missedByTutor': 1,
      'missedByLearner': 1,
      'ratePerHour': 420,
      'totalBooking': 5040,
      'inHandBooking': 3780,
      'credited': 3150,
      'pending': 630,
    },
  ];

  int get _totalBooked => _bookings.fold(0, (sum, b) => sum + (b['totalSessions'] as int));
  int get _totalCompleted => _bookings.fold(0, (sum, b) => sum + (b['completed'] as int));
  int get _totalMissedByTutor => _bookings.fold(0, (sum, b) => sum + (b['missedByTutor'] as int));
  int get _totalMissedByLearner => _bookings.fold(0, (sum, b) => sum + (b['missedByLearner'] as int));
  double get _totalBookingAmount => _bookings.fold(0.0, (sum, b) => sum + (b['totalBooking'] as int));
  double get _totalInHand => _bookings.fold(0.0, (sum, b) => sum + (b['inHandBooking'] as int));
  double get _totalCredited => _bookings.fold(0.0, (sum, b) => sum + (b['credited'] as int));
  double get _totalPending => _bookings.fold(0.0, (sum, b) => sum + (b['pending'] as int));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReportFilters(
          cs: widget.cs,
          tt: widget.tt,
          selectedStudent: _selectedStudent,
          dateRange: _dateRange,
          studentsList: _students,
          onStudentFilterTap: () async {
            final selected = await showModalBottomSheet<String>(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => Container(
                decoration: BoxDecoration(
                  color: widget.cs.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: widget.cs.onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Select Student', style: widget.tt.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 20),
                    ..._students.map((student) => ListTile(
                      title: Text(student),
                      selected: _selectedStudent == student,
                      selectedTileColor: widget.cs.tertiaryContainer.withValues(alpha: 0.3),
                      onTap: () => Navigator.pop(context, student),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    )),
                  ],
                ),
              ),
            );
            if (selected != null) {
              setState(() => _selectedStudent = selected);
            }
          },
          onDateFilterTap: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2024, 1, 1),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: widget.cs.copyWith(
                      primary: widget.cs.tertiary,
                      onPrimary: widget.cs.onTertiaryContainer,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() => _dateRange = picked);
            }
          },
          onClearFilters: () {
            setState(() {
              _selectedStudent = null;
              _dateRange = null;
            });
          },
        ),
        // Summary Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.cs.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: widget.cs.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.cs.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.account_balance_wallet_rounded, size: 20, color: widget.cs.tertiary),
                  ),
                  const SizedBox(width: 12),
                  Text('Payout Summary', style: widget.tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Booking', style: widget.tt.labelSmall?.copyWith(color: widget.cs.onSurfaceVariant)),
                        const SizedBox(height: 6),
                        Text('₹${_totalBookingAmount.toStringAsFixed(0)}', style: widget.tt.headlineMedium?.copyWith(fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('In-Hand (75%)', style: widget.tt.labelSmall?.copyWith(color: widget.cs.onSurfaceVariant)),
                        const SizedBox(height: 6),
                        Text('₹${_totalInHand.toStringAsFixed(0)}', style: widget.tt.headlineMedium?.copyWith(fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: widget.cs.outlineVariant.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Credited', style: widget.tt.labelSmall?.copyWith(color: widget.cs.tertiary, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('₹${_totalCredited.toStringAsFixed(0)}', style: widget.tt.headlineMedium?.copyWith(fontWeight: FontWeight.w400, color: widget.cs.tertiary)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pending', style: widget.tt.labelSmall?.copyWith(color: widget.cs.onSurfaceVariant)),
                        const SizedBox(height: 6),
                        Text('₹${_totalPending.toStringAsFixed(0)}', style: widget.tt.headlineMedium?.copyWith(fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Sessions
        Row(
          children: [
            Expanded(child: _SessionCard(label: 'Booked', value: _totalBooked.toString(), icon: Icons.event_rounded, cs: widget.cs, tt: widget.tt)),
            const SizedBox(width: 12),
            Expanded(child: _SessionCard(label: 'Completed', value: _totalCompleted.toString(), icon: Icons.check_circle_rounded, cs: widget.cs, tt: widget.tt)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _SessionCard(label: 'Missed by Me', value: _totalMissedByTutor.toString(), icon: Icons.cancel_rounded, cs: widget.cs, tt: widget.tt)),
            const SizedBox(width: 12),
            Expanded(child: _SessionCard(label: 'Missed by Learner', value: _totalMissedByLearner.toString(), icon: Icons.event_busy_rounded, cs: widget.cs, tt: widget.tt)),
          ],
        ),
        const SizedBox(height: 24),
        ..._bookings.map((b) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _BookingCard(booking: b, cs: widget.cs, tt: widget.tt),
        )),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ColorScheme cs;
  final TextTheme tt;

  const _SessionCard({required this.label, required this.value, required this.icon, required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
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
          Text(value, style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w400)),
          const SizedBox(height: 4),
          Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final ColorScheme cs;
  final TextTheme tt;

  const _BookingCard({required this.booking, required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking['student'], style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('${booking['subject']} • ₹${booking['ratePerHour']}/hr', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.tertiaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${(booking['completed'] / booking['totalSessions'] * 100).toStringAsFixed(0)}%',
                  style: tt.labelMedium?.copyWith(color: cs.onTertiaryContainer, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Stat(label: 'Booked', value: booking['totalSessions'].toString(), cs: cs, tt: tt),
              _Stat(label: 'Done', value: booking['completed'].toString(), cs: cs, tt: tt),
              _Stat(label: 'Me', value: booking['missedByTutor'].toString(), cs: cs, tt: tt),
              _Stat(label: 'Them', value: booking['missedByLearner'].toString(), cs: cs, tt: tt),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _Amount(label: 'Booking', value: '₹${booking['totalBooking']}', cs: cs, tt: tt)),
              Expanded(child: _Amount(label: 'In-Hand', value: '₹${booking['inHandBooking']}', cs: cs, tt: tt)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _Amount(label: 'Credited', value: '₹${booking['credited']}', highlight: true, cs: cs, tt: tt)),
              Expanded(child: _Amount(label: 'Pending', value: '₹${booking['pending']}', cs: cs, tt: tt)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme cs;
  final TextTheme tt;

  const _Stat({required this.label, required this.value, required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w400)),
          const SizedBox(height: 2),
          Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _Amount extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final ColorScheme cs;
  final TextTheme tt;

  const _Amount({required this.label, required this.value, this.highlight = false, required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: tt.labelSmall?.copyWith(color: highlight ? cs.tertiary : cs.onSurfaceVariant, fontWeight: highlight ? FontWeight.w600 : FontWeight.w400)),
        const SizedBox(height: 4),
        Text(value, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w400, color: highlight ? cs.tertiary : cs.onSurface)),
      ],
    );
  }
}
