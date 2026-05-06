import 'package:flutter/material.dart';
import '../../../widgets/requests/request_model.dart';
import '../../../widgets/requests/request_filter_bar.dart';
import '../../../widgets/requests/request_tile.dart';
import '../../../widgets/requests/mock_requests.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  RequestType? _filterType;
  RequestStatus? _filterStatus;
  String? _filterTutor;

  List<BookingRequest> get _filtered {
    return mockRequests.where((r) {
      if (_filterType != null && r.type != _filterType) return false;
      if (_filterStatus != null && r.status != _filterStatus) return false;
      if (_filterTutor != null && r.tutor != _filterTutor) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
  }

  List<String> get _tutors => mockRequests.map((r) => r.tutor).toSet().toList()..sort();

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
            child: requests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: cs.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text('No requests found', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
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
