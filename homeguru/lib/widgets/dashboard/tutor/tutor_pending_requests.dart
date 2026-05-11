import 'package:flutter/material.dart';
import '../../../screens/dashboard/tutor/tutor_dashboard.dart';
import '../../../services/request_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../requests/tutor_request_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TutorPendingRequests extends StatefulWidget {
  const TutorPendingRequests({super.key});

  @override
  State<TutorPendingRequests> createState() => _TutorPendingRequestsState();
}

class _TutorPendingRequestsState extends State<TutorPendingRequests> {
  List<dynamic> _pending = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tutorId = prefs.getString('userId');
      if (tutorId != null) {
        final requests = await RequestService.fetchRequests(
          tutorId: tutorId,
          status: 'pending',
        );
        if (mounted) {
          setState(() {
            _pending = requests;
            _loading = false;
          });
          
          if (requests.isNotEmpty) {
            _showRequestSheet(requests[0]);
          }
        }
      }
    } catch (e) {
      print('Error loading pending requests: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showRequestSheet(dynamic req) {
    final request = TutorBookingRequest(
      id: req['requestId']?.toString() ?? '',
      studentName: req['studentName']?.toString() ?? '',
      studentImage: req['studentImage']?.toString() ?? '',
      subject: req['subject']?.toString() ?? '',
      level: req['level']?.toString() ?? '',
      type: req['type']?.toString() == 'paid' ? TutorRequestType.paid : TutorRequestType.demo,
      status: TutorRequestStatus.pending,
      requestedAt: DateTime.tryParse(req['createdAt']?.toString() ?? '') ?? DateTime.now(),
      respondedAt: null,
      preferredSlot: req['preferredSlot']?.toString(),
      schedule: req['preferredDays'] != null ? req['preferredDays'].toString() : null,
      totalSessions: req['totalSessions'] as int?,
      perHourRate: (req['perHourRate'] as num?)?.toDouble(),
      classesPerWeek: req['classesPerWeek'] as int?,
      totalPrice: (req['totalPrice'] as num?)?.toDouble(),
      inHandAmount: req['totalPrice'] != null ? (req['totalPrice'] as num).toDouble() * 0.85 : null,
      note: req['message']?.toString(),
      originalDate: null,
      originalTime: null,
      newDate: null,
      newTime: null,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => _RequestDetailsSheet(
        request: request,
        onAccept: () async {
          Navigator.pop(ctx);
          await _handleAccept(req['requestId']);
        },
        onDecline: () async {
          Navigator.pop(ctx);
          await _handleDecline(req['requestId']);
        },
      ),
    );
  }

  Future<void> _handleAccept(String requestId) async {
    try {
      final req = _pending.firstWhere((r) => r['requestId'] == requestId);
      final type = req['type'] == 'paid' ? 'paid' : 'demo';
      await RequestService.updateRequestStatus(
        requestId: requestId,
        type: type,
        action: 'accept',
      );
      await _loadRequests();
    } catch (e) {
      print('Error accepting request: $e');
    }
  }

  Future<void> _handleDecline(String requestId) async {
    try {
      final req = _pending.firstWhere((r) => r['requestId'] == requestId);
      final type = req['type'] == 'paid' ? 'paid' : 'demo';
      await RequestService.updateRequestStatus(
        requestId: requestId,
        type: type,
        action: 'decline',
      );
      await _loadRequests();
    } catch (e) {
      print('Error declining request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
        if (_loading)
          Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: const Center(child: CircularProgressIndicator()),
          )
        else if (_pending.isEmpty)
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
              itemCount: _pending.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final req = _pending[i];
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
    final local = d.toLocal();
    final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final m = local.minute.toString().padLeft(2, '0');
    final p = local.hour >= 12 ? 'PM' : 'AM';
    return '${local.day} ${months[local.month - 1]}, ${local.year} at $h:$m $p';
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
                  backgroundImage: CachedNetworkImageProvider(request.studentImage),
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
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: cs.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      'Requested ${_fmtDate(request.requestedAt)}',
                      style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
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
                                  Expanded(child: Text(_fmtDate(request.originalDate!), style: tt.bodySmall)),
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
                                  Expanded(child: Text(_fmtDate(request.newDate!), style: tt.bodySmall?.copyWith(color: cs.tertiary, fontWeight: FontWeight.w600))),
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
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: cs.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      'Requested ${_fmtDate(request.requestedAt)}',
                      style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
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
                          Text('Platform Fee (15%)', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                          Text('- ₹${((request.totalPrice! * 0.15)).toStringAsFixed(0)}', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
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
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
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
                    onPressed: onAccept,
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
