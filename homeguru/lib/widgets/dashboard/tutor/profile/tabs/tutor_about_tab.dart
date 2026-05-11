import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../services/tutor_profile_service.dart';
import '../../../../../services/blog_service.dart';
import '../tutor_intro_video.dart';
import '../../../../../screens/shared/feed/feed_models.dart';
import '../../../../../screens/shared/feed/blog_detail_screen.dart';

class TutorAboutTab extends StatefulWidget {
  const TutorAboutTab({super.key, this.viewMode = false});

  final bool viewMode;

  @override
  State<TutorAboutTab> createState() => _TutorAboutTabState();
}

class _TutorAboutTabState extends State<TutorAboutTab> {
  bool _loading = true;
  String _bio = '';
  List<Map<String, String>> _experience = [];
  String _youtubeLink = '';
  List<Map<String, dynamic>> _rates = [];
  List<String> _tags = [];
  Map<String, dynamic>? _profile;
  List<HgBlog> _blogs = [];

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
      _youtubeLink = data['youtubeVideoLink'] ?? '';

      // Experience: handle array (LinkedIn) or legacy string
      if (data['experience'] != null) {
        if (data['experience'] is List) {
          _experience = (data['experience'] as List)
              .map((e) => Map<String, String>.from(
                  (e as Map).map((k, v) => MapEntry(k.toString(), v.toString()))))
              .toList();
        } else if (data['experience'] is String && (data['experience'] as String).isNotEmpty) {
          _experience = [{'title': 'Teaching', 'org': '', 'period': data['experience']}];
        }
      }
      _rates = data['rates'] != null
          ? (data['rates'] as List).map((r) => Map<String, dynamic>.from(r)).toList()
          : [];

      // Build tags from subjects
      if (data['subjects'] != null) {
        final subjects = data['subjects'] as Map<String, dynamic>;
        _tags = _extractTags(subjects);
      }

      // Blogs — fetch from blogs API
      final blogsData = await BlogService.fetchByTutor(tutorId);
      _blogs = blogsData.map((b) => HgBlog(
        id: b['blogId']?.toString() ?? '',
        title: b['title']?.toString() ?? '',
        body: b['body']?.toString() ?? '',
        imageUrl: b['coverImageUrl']?.toString() ?? '',
        authorName: b['authorName']?.toString() ?? '',
        authorAvatar: b['authorAvatar']?.toString() ?? '',
        tags: b['tag'] != null ? [b['tag'].toString()] : [],
        publishedAt: b['createdAt']?.toString() ?? '',
      )).toList();
    }

    if (mounted) setState(() => _loading = false);
  }

  List<String> _extractTags(Map<String, dynamic> subjectsData) {
    final tags = <String>[];
    final schooling = subjectsData['schooling'];
    if (schooling != null && schooling['subjectsByBoardAndGrade'] != null) {
      final byBoard = schooling['subjectsByBoardAndGrade'] as Map<String, dynamic>;
      for (final boardEntry in byBoard.entries) {
        if (boardEntry.value is Map) {
          for (final gradeEntry in (boardEntry.value as Map).entries) {
            if (gradeEntry.value is List) {
              for (final subject in gradeEntry.value) {
                tags.add('$subject • ${boardEntry.key} • ${gradeEntry.key}');
              }
            }
          }
        }
      }
    }
    final levels = subjectsData['teachingLevels'];
    if (levels is List) tags.addAll(levels.cast<String>());
    return tags;
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
                    children: _tags.map((tag) {
                      final parts = tag.split(' • ');
                      final subject = parts.first;
                      final meta = parts.length > 1 ? parts.sublist(1).join(' • ') : '';
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.tertiaryContainer.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: cs.tertiary.withValues(alpha: 0.2)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(subject, style: tt.labelMedium?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w600)),
                          if (meta.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Text(meta, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 10)),
                          ],
                        ]),
                      );
                    }).toList(),
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
          ..._rates.map((rate) {
            final board = rate['board']?.toString() ?? '';
            final grade = rate['grade']?.toString() ?? '';
            final subject = rate['subject']?.toString() ?? '';
            final meta = board.isNotEmpty ? '$board • $grade' : '';
            return _SubjectPricingRow(
              subject: subject,
              meta: meta,
              rateInr: rate['inr'] ?? 0,
              rateUsd: rate['international'] ?? 0,
              cs: cs,
              tt: tt,
            );
          }),
          const SizedBox(height: 32),
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 32),
        ],

        // Experience (LinkedIn-style)
        if (_experience.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Experience', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                ..._experience.map((exp) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: cs.tertiaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.work_outline, size: 18, color: cs.tertiary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(exp['title'] ?? '', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                            if ((exp['org'] ?? '').isNotEmpty)
                              Text(exp['org']!, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                            if ((exp['period'] ?? '').isNotEmpty)
                              Text(exp['period']!, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 32),
        ],

        // Blogs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('My Blogs', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 12),
        if (_blogs.isNotEmpty)
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _blogs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _MiniProfileBlogCard(blog: _blogs[i], cs: cs, tt: tt),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.article_outlined, size: 32, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                  const SizedBox(height: 8),
                  Text('No blogs yet', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        const SizedBox(height: 32),

        // Empty state
        if (_bio.isEmpty && _rates.isEmpty && _experience.isEmpty && _youtubeLink.isEmpty)
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

class _MiniProfileBlogCard extends StatelessWidget {
  const _MiniProfileBlogCard({required this.blog, required this.cs, required this.tt});
  final HgBlog blog;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => BlogDetailScreen(blog: blog))),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (blog.imageUrl.isNotEmpty)
              Image.network(blog.imageUrl, height: 90, width: 200, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(height: 90, color: cs.surfaceContainerHighest))
            else
              Container(height: 90, color: cs.surfaceContainerHighest,
                child: Center(child: Icon(Icons.article_outlined, color: cs.onSurfaceVariant.withValues(alpha: 0.3)))),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(blog.title, style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(blog.tags.isNotEmpty ? blog.tags.first : '', style: tt.labelSmall?.copyWith(color: cs.tertiary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectPricingRow extends StatelessWidget {
  const _SubjectPricingRow({
    required this.subject,
    this.meta = '',
    required this.rateInr,
    required this.rateUsd,
    required this.cs,
    required this.tt,
  });
  final String subject;
  final String meta;
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
                if (meta.isNotEmpty)
                  Text(meta, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 11)),
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
