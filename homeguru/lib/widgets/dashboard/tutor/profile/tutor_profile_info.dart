import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/tutor_profile_service.dart';
import '../../../../screens/dashboard/tutor/profile/tutor_profile_edit_screen.dart';
import 'boost_profile_sheet.dart';
import 'boost_analytics_screen.dart';

class TutorProfileInfo extends StatefulWidget {
  const TutorProfileInfo({super.key, this.viewMode = false});

  final bool viewMode;

  @override
  State<TutorProfileInfo> createState() => _TutorProfileInfoState();
}

class _TutorProfileInfoState extends State<TutorProfileInfo> {
  bool _isBoosted = false;
  DateTime? _boostEndDate;
  String? _boostCity;
  int? _boostBudget;

  // Real data from API
  String _name = '';
  String _bio = '';
  String _email = '';
  bool _isVerified = false;
  bool _isActive = false;
  List<Map<String, String>> _subjectTags = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final tutorId = prefs.getString('userId');
    if (tutorId == null) return;

    final result = await TutorProfileService.getTutorProfile(tutorId);
    if (result['success'] == true && mounted) {
      final data = result['data'] as Map<String, dynamic>;
      final profile = data['profile'] as Map<String, dynamic>?;
      setState(() {
        _name = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
        _bio = profile?['bio'] ?? '';
        _email = data['email'] ?? '';
        _isVerified = data['isVerified'] == true;
        _isActive = data['isActive'] == true;

        // Extract subjects with board context
        if (data['rates'] != null) {
          _subjectTags = (data['rates'] as List).map((r) {
            final board = r['board']?.toString() ?? '';
            final grade = r['grade']?.toString() ?? '';
            final subject = r['subject']?.toString() ?? '';
            return {'label': board.isNotEmpty ? '$subject • $board • $grade' : subject};
          }).toList().cast<Map<String, String>>();
        } else if (data['subjects'] != null) {
          _subjectTags = _extractSubjectTags(data['subjects'] as Map<String, dynamic>);
        }
      });
    }
  }

  List<Map<String, String>> _extractSubjectTags(Map<String, dynamic> subjectsData) {
    final tags = <Map<String, String>>[];
    final schooling = subjectsData['schooling'];
    if (schooling != null && schooling['subjectsByBoardAndGrade'] != null) {
      final byBoard = schooling['subjectsByBoardAndGrade'] as Map<String, dynamic>;
      for (final boardEntry in byBoard.entries) {
        if (boardEntry.value is Map) {
          for (final gradeEntry in (boardEntry.value as Map).entries) {
            if (gradeEntry.value is List) {
              for (final subject in gradeEntry.value) {
                tags.add({'label': '$subject • ${boardEntry.key} • ${gradeEntry.key}'});
              }
            }
          }
        }
      }
    }
    return tags;
  }

  void _showBoostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const BoostProfileSheet(),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          _isBoosted = true;
          _boostCity = result['city'];
          _boostBudget = result['budget'];
          _boostEndDate = DateTime.now().add(Duration(days: result['duration']));
        });
      }
    });
  }

  void _showAnalytics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BoostAnalyticsScreen(
          city: _boostCity!,
          budget: _boostBudget!,
          duration: (_boostEndDate!.difference(DateTime.now()).inDays + 3),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  _name.isNotEmpty ? _name : 'Tutor',
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              if (_isVerified) ...[
                const SizedBox(width: 5),
                Icon(Icons.verified_rounded, size: 16, color: cs.tertiary),
              ],
              if (_isBoosted) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.workspace_premium, size: 10, color: Colors.white),
                      SizedBox(width: 2),
                      Text('PREMIUM', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: cs.tertiary, borderRadius: BorderRadius.circular(4)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.rocket_launch, size: 10, color: cs.onTertiary),
                      const SizedBox(width: 2),
                      Text('BOOSTED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: cs.onTertiary, letterSpacing: 0.5)),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (_email.isNotEmpty) ...[
            const SizedBox(height: 1),
            Text(_email, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ],
          if (_bio.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(_bio, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 10),
          if (!_isActive && !widget.viewMode) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.errorContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16, color: cs.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Complete your profile to go live',
                      style: tt.labelSmall?.copyWith(color: cs.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (!widget.viewMode) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const TutorProfileEditScreen(),
                      ));
                      if (result == true) _loadProfile();
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit Profile'),
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.tertiary,
                      foregroundColor: cs.onTertiary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _isBoosted
                      ? OutlinedButton.icon(
                          onPressed: _showAnalytics,
                          icon: Icon(Icons.analytics_outlined, size: 18, color: cs.tertiary),
                          label: Text('Analytics', style: TextStyle(color: cs.tertiary)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: cs.tertiary, width: 1.5),
                          ),
                        )
                      : OutlinedButton.icon(
                          onPressed: _showBoostSheet,
                          icon: Icon(Icons.rocket_launch_rounded, size: 18, color: cs.tertiary),
                          label: Text('Boost', style: TextStyle(color: cs.tertiary)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: cs.tertiary, width: 1.5),
                          ),
                        ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}


