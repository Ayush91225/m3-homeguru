import 'package:flutter/material.dart';
import '../../../screens/dashboard/tutor/tutor_dashboard.dart';
import '../../../services/request_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../requests/tutor_request_model.dart';
import '../../requests/tutor_request_tile.dart';

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
      builder: (ctx) => _RequestDetailsSheetWrapper(
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

class _RequestDetailsSheetWrapper extends StatelessWidget {
  final TutorBookingRequest request;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const _RequestDetailsSheetWrapper({
    required this.request,
    this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return TutorRequestTile(
      request: request,
      onAccept: onAccept,
      onDecline: onDecline,
    ).build(context);
  }
}
