import 'package:flutter/material.dart';
import '../../../widgets/requests/request_model.dart';
import '../../../widgets/requests/request_filter_bar.dart';
import '../../../widgets/requests/request_tile.dart';
import '../../../services/request_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  RequestType? _filterType;
  RequestStatus? _filterStatus;
  String? _filterTutor;
  List<BookingRequest> _allRequests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final learnerId = prefs.getString('userId');
      if (learnerId != null) {
        final requests = await RequestService.fetchRequests(learnerId: learnerId);
        setState(() {
          _allRequests = requests.map((r) => BookingRequest(
            id: r['requestId']?.toString() ?? '',
            tutor: r['tutorId']?.toString() ?? '',
            tutorImage: '',
            subject: r['subject']?.toString() ?? '',
            level: r['level']?.toString() ?? '',
            type: r['type']?.toString() == 'paid' ? RequestType.paid : (r['type']?.toString() == 'paid-demo' ? RequestType.paidDemo : RequestType.demo),
            status: switch (r['status']?.toString()) {
              'accepted' => RequestStatus.accepted,
              'declined' => RequestStatus.rejected,
              _ => RequestStatus.pending
            },
            requestedAt: DateTime.tryParse(r['createdAt']?.toString() ?? '') ?? DateTime.now(),
            respondedAt: r['respondedAt'] != null ? DateTime.tryParse(r['respondedAt'].toString()) : null,
            preferredSlot: r['preferredSlot']?.toString(),
            schedule: r['preferredDays'] != null ? r['preferredDays'].toString() : null,
            sessionsBooked: r['totalSessions'] as int?,
            perHourPrice: (r['perHourRate'] as num?)?.toDouble(),
            classesPerWeek: r['classesPerWeek'] as int?,
            durationMonths: r['months'] as int?,
            isPaid: false,
            bookingAcceptedAt: r['respondedAt'] != null ? DateTime.tryParse(r['respondedAt'].toString()) : null,
            rejectionReason: r['status']?.toString() == 'declined' ? 'Request declined by tutor' : null,
          )).toList();
          _loading = false;
        });
      }
    } catch (e) {
      print('Error loading requests: $e');
      setState(() => _loading = false);
    }
  }

  List<BookingRequest> get _filtered {
    return _allRequests.where((r) {
      if (_filterType != null && r.type != _filterType) return false;
      if (_filterStatus != null && r.status != _filterStatus) return false;
      if (_filterTutor != null && r.tutor != _filterTutor) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
  }

  List<String> get _tutors => _allRequests.map((r) => r.tutor).toSet().toList()..sort();

  bool get _hasFilters => _filterType != null || _filterStatus != null || _filterTutor != null;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final requests = _filtered;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('My Requests', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
        actions: [
          if (_hasFilters)
            TextButton(
              onPressed: () => setState(() {
                _filterType = null;
                _filterStatus = null;
                _filterTutor = null;
              }),
              child: Text('Clear', style: tt.labelMedium?.copyWith(color: cs.primary)),
            ),
        ],
      ),
      body: Column(
        children: [
          RequestFilterBar(
            filterType: _filterType,
            filterStatus: _filterStatus,
            filterTutor: _filterTutor,
            tutors: _tutors,
            onTypeChanged: (v) => setState(() => _filterType = v),
            onStatusChanged: (v) => setState(() => _filterStatus = v),
            onTutorChanged: (v) => setState(() => _filterTutor = v),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : requests.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text('No requests', style: tt.titleLarge?.copyWith(color: cs.onSurface)),
                            const SizedBox(height: 8),
                            Text('Your booking requests will appear here', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 32),
                        itemCount: requests.length,
                        itemBuilder: (context, i) => RequestTile(request: requests[i]),
                      ),
          ),
        ],
      ),
    );
  }
}
