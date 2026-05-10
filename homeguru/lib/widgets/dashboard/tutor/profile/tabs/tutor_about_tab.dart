import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../services/tutor_profile_service.dart';
import '../tutor_intro_video.dart';

class TutorAboutTab extends StatefulWidget {
  const TutorAboutTab({super.key, this.viewMode = false});

  final bool viewMode;

  @override
  State<TutorAboutTab> createState() => _TutorAboutTabState();
}

class _TutorAboutTabState extends State<TutorAboutTab> {
  bool _loading = true;
  String _bio = '';
  String _experience = '';
  String _youtubeLink = '';
  List<Map<String, dynamic>> _rates = [];
  List<String> _tags = [];
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final tutorId = prefs.getString('userId');
    if (tutorId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final result = await TutorProfileService.getTutorProfile(tutorId);
    if (result['success'] == true && mounted) {
      final data = result['data'] as Map<String, dynamic>;
      _profile = data['profile'] as Map<String, dynamic>?;
      _bio = _profile?['bio'] ?? '';
      _experience = data['experience'] ?? '';
      _youtubeLink = data['youtubeVideoLink'] ?? '';
      _rates = data['rates'] != null
          ? (data['rates'] as List).map((r) => Map<String, dynamic>.from(r)).toList()
          : [];

      // Build tags from subjects
      if (data['subjects'] != null) {
        final subjects = data['subjects'] as Map<String, dynamic>;
        _tags = _extractTags(subjects);
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  List<String> _extractTags(Map<String, dynamic> subjectsData) {
    final tags = <String>{};
    final schooling = subjectsData['schooling'];
    if (schooling != null && schooling['subjectsByBoardAndGrade'] != null) {
      final byBoard = schooling['subjectsByBoardAndGrade'] as Map<String, dynamic>;
      for (final board in byBoard.values) {
        if (board is Map) {
          for (final subjects in board.values) {
            if (subjects is List) tags.addAll(subjects.cast<String>());
          }
        }
      }
    }
    final levels = subjectsData['teachingLevels'];
    if (levels is List) tags.addAll(levels.cast<String>());
    return tags.toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (_loading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(),
      ));
    }

    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        const SizedBox(height: 24),

        // Intro Video
        if (_youtubeLink.isNotEmpty && !widget.viewMode) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TutorIntroVideo(videoUrl: _youtubeLink, height: 200),
          ),
          const SizedBox(height: 32),
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 32),
        ],

        // Bio Section
        if (_bio.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('About', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Text(_bio, style: tt.bodyMedium?.copyWith(color: cs.onSurface, height: 1.6)),
                if (_tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: cs.tertiaryContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: cs.tertiary.withValues(alpha: 0.2)),
                      ),
                      child: Text(tag, style: tt.labelSmall?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w500)),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),

        if (_bio.isNotEmpty) ...[
          const SizedBox(height: 32),
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 32),
        ],

        // Subjects & Pricing
        if (_rates.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Subjects & Pricing', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Per hour rates', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: 20),
              ],
            ),
          ),
          ..._rates.map((rate) => _SubjectPricingRow(
            subject: rate['subject'] ?? '',
            rateInr: rate['inr'] ?? 0,
            rateUsd: rate['international'] ?? 0,
            cs: cs,
            tt: tt,
          )),
          const SizedBox(height: 32),
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 32),
        ],

        // Experience
        if (_experience.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Experience', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Text(_experience, style: tt.bodyMedium?.copyWith(color: cs.onSurface, height: 1.6)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 32),
        ],

        // Education (from onboarding profile if available)
        if (_profile != null && _profile!['certificates'] != null && (_profile!['certificates'] as List).isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Certificates', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                ...(_profile!['certificates'] as List).map((cert) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.workspace_premium_rounded, size: 20, color: cs.tertiary),
                      const SizedBox(width: 12),
                      Expanded(child: Text(cert.toString(), style: tt.bodyMedium)),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],

        // Empty state
        if (_bio.isEmpty && _rates.isEmpty && _experience.isEmpty)
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(Icons.edit_note_rounded, size: 48, color: cs.onSurfaceVariant.withOpacity(0.4)),
                const SizedBox(height: 12),
                Text('Profile not yet completed', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text('Tap "Edit Profile" to add your details', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),

        const SizedBox(height: 40),
      ],
    );
  }
}

class _SubjectPricingRow extends StatelessWidget {
  const _SubjectPricingRow({
    required this.subject,
    required this.rateInr,
    required this.rateUsd,
    required this.cs,
    required this.tt,
  });
  final String subject;
  final int rateInr;
  final int rateUsd;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject, style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                if (rateUsd > 0)
                  Text('\$$rateUsd/hr international', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Text(
            '₹$rateInr/hr',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: cs.tertiary),
          ),
        ],
      ),
    );
  }
}
