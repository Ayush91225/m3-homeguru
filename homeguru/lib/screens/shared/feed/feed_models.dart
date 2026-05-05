import 'dart:convert';
import 'package:http/http.dart' as http;

// ─── Article (external) ───────────────────────────────────────────────────────

class FeedArticle {
  final String title;
  final String description;
  final String url;
  final String imageUrl;
  final String source;
  final String publishedAt;

  const FeedArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.imageUrl,
    required this.source,
    required this.publishedAt,
  });
}

// ─── HG Blog (HomeGuru authored) ─────────────────────────────────────────────

class HgBlog {
  final String id;
  final String title;
  final String body;
  final String imageUrl;
  final String authorName;
  final String authorAvatar;
  final List<String> tags;
  final String publishedAt;

  const HgBlog({
    required this.id,
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.authorName,
    required this.authorAvatar,
    required this.tags,
    required this.publishedAt,
  });
}

// ─── Mock HG blogs ────────────────────────────────────────────────────────────

final List<HgBlog> mockHgBlogs = [
  HgBlog(
    id: '1',
    title: 'How to Find the Perfect Tutor for Your Child',
    body:
        'Finding the right tutor can transform your child\'s academic journey. Here are the key things to look for: subject expertise, teaching style compatibility, and consistent availability.\n\nStart by identifying your child\'s specific weak areas. A tutor who specialises in those topics will be far more effective than a generalist. Ask for a trial session before committing — most good tutors are happy to offer one.\n\nCommunication is equally important. A tutor who keeps parents informed about progress builds trust and ensures everyone is aligned on goals. Look for someone who sets measurable milestones and celebrates small wins.\n\nFinally, consistency matters more than intensity. Two focused sessions a week over three months will outperform cramming every day for two weeks. Build a sustainable schedule and stick to it.',
    imageUrl: 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800',
    authorName: 'HomeGuru Team',
    authorAvatar: 'https://i.pravatar.cc/150?img=12',
    tags: ['Parenting', 'Education', 'Tips'],
    publishedAt: '12 Jul 2025',
  ),
  HgBlog(
    id: '2',
    title: '5 Study Techniques Backed by Science',
    body:
        'Not all study methods are created equal. Research consistently shows that certain techniques lead to far better retention and understanding.\n\n1. Spaced Repetition — Review material at increasing intervals. Apps like Anki make this easy.\n2. Active Recall — Test yourself instead of re-reading. Close the book and write down everything you remember.\n3. The Feynman Technique — Explain the concept in simple language as if teaching a child. Gaps in your explanation reveal gaps in your knowledge.\n4. Interleaving — Mix different subjects or problem types in a single session rather than blocking one topic.\n5. Elaborative Interrogation — Ask "why" and "how" questions as you study to build deeper connections.\n\nCombining two or three of these in each session will dramatically improve your results.',
    imageUrl: 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=800',
    authorName: 'Priya Sharma',
    authorAvatar: 'https://i.pravatar.cc/150?img=47',
    tags: ['Study Tips', 'Science', 'Productivity'],
    publishedAt: '10 Jul 2025',
  ),
  HgBlog(
    id: '3',
    title: 'Online vs Offline Tutoring: What Works Best?',
    body:
        'The debate between online and offline tutoring has intensified since 2020. Both have genuine strengths depending on the learner\'s needs.\n\nOnline tutoring offers flexibility, access to a global pool of tutors, and the ability to record sessions for review. It works especially well for older students who are self-motivated and comfortable with technology.\n\nOffline tutoring, on the other hand, provides a distraction-free environment and stronger personal rapport. Younger children often benefit from the physical presence of a tutor who can observe body language and adjust in real time.\n\nThe best approach? A hybrid model. Use online sessions for concept delivery and offline sessions for practice and doubt-clearing. HomeGuru supports both formats seamlessly.',
    imageUrl: 'https://images.unsplash.com/photo-1588072432836-e10032774350?w=800',
    authorName: 'Rahul Verma',
    authorAvatar: 'https://i.pravatar.cc/150?img=33',
    tags: ['Online Learning', 'Comparison'],
    publishedAt: '8 Jul 2025',
  ),
  HgBlog(
    id: '4',
    title: 'Building a Growth Mindset in Students',
    body:
        'Carol Dweck\'s research on growth mindset has changed how educators think about potential. The core idea: intelligence is not fixed — it grows with effort and the right strategies.\n\nAs a parent or tutor, the language you use matters enormously. Replace "you\'re so smart" with "you worked really hard on that." Praise the process, not the outcome.\n\nEncourage students to embrace mistakes as data, not failure. When a student gets something wrong, ask: "What can we learn from this?" rather than moving on quickly.\n\nSet stretch goals — targets that are just beyond current ability. This keeps students in the productive zone of challenge without overwhelming them.',
    imageUrl: 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800',
    authorName: 'Ananya Iyer',
    authorAvatar: 'https://i.pravatar.cc/150?img=25',
    tags: ['Mindset', 'Psychology', 'Education'],
    publishedAt: '5 Jul 2025',
  ),
  HgBlog(
    id: '5',
    title: 'How HomeGuru Matches You with the Right Tutor',
    body:
        'At HomeGuru, we believe the tutor-student match is everything. Our matching algorithm considers subject expertise, teaching style, availability, location preference, and budget — but we go further.\n\nWe analyse past session feedback to understand how a tutor communicates and adapts. We look at student learning profiles to identify whether they need a structured, step-by-step approach or a more exploratory, discussion-based style.\n\nEvery match starts with a free trial session. If it\'s not the right fit, we rematch at no cost. Our goal is a long-term relationship, not a one-off booking.\n\nOver 85% of HomeGuru students who complete a trial session go on to book regular sessions. That\'s the power of a thoughtful match.',
    imageUrl: 'https://images.unsplash.com/photo-1531482615713-2afd69097998?w=800',
    authorName: 'HomeGuru Team',
    authorAvatar: 'https://i.pravatar.cc/150?img=12',
    tags: ['HomeGuru', 'Matching', 'Platform'],
    publishedAt: '2 Jul 2025',
  ),
];

// ─── Service ──────────────────────────────────────────────────────────────────

class FeedService {
  static const _devToBase =
      'https://dev.to/api/articles?tag=education&state=rising';
  static const _hnTopUrl =
      'https://hacker-news.firebaseio.com/v0/topstories.json';
  static const _hnItemUrl =
      'https://hacker-news.firebaseio.com/v0/item/';

  static const _months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];

  static String _fmtDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day} ${_months[dt.month - 1]} ${dt.year}';
    } catch (_) { return ''; }
  }

  static String _fmtTs(dynamic ts) {
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch((ts as int) * 1000).toLocal();
      return '${dt.day} ${_months[dt.month - 1]} ${dt.year}';
    } catch (_) { return ''; }
  }

  /// page is 1-based; returns up to 10 items per page
  static Future<List<FeedArticle>> fetchBlogs(int page) async {
    try {
      final url = '$_devToBase&per_page=10&page=$page';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return [];
      final List data = json.decode(res.body);
      return data.map((e) {
        final img = (e['cover_image'] ?? e['social_image'] ?? '') as String;
        return FeedArticle(
          title: e['title'] ?? '',
          description: e['description'] ?? '',
          url: e['url'] ?? '',
          imageUrl: img,
          source: 'dev.to · ${e['user']?['name'] ?? ''}',
          publishedAt: _fmtDate(e['published_at'] ?? ''),
        );
      }).where((a) => a.title.isNotEmpty).toList();
    } catch (_) { return []; }
  }

  // Cache the full HN id list so pagination works without re-fetching
  static List<int>? hnIds;

  static Future<List<FeedArticle>> fetchNews(int page) async {
    try {
      if (hnIds == null) {
        final r = await http.get(Uri.parse(_hnTopUrl)).timeout(const Duration(seconds: 10));
        if (r.statusCode != 200) return [];
        hnIds = List<int>.from(json.decode(r.body));
      }
      final pageIds = hnIds!.skip((page - 1) * 15).take(15).toList();
      final responses = await Future.wait(
        pageIds.map((id) => http
            .get(Uri.parse('$_hnItemUrl$id.json'))
            .timeout(const Duration(seconds: 8))),
        eagerError: false,
      );
      final articles = <FeedArticle>[];
      for (final r in responses) {
        try {
          if (r.statusCode != 200) continue;
          final e = json.decode(r.body);
          if (e == null || e['url'] == null) continue;
          articles.add(FeedArticle(
            title: e['title'] ?? '',
            description: 'by ${e['by'] ?? '?'} · ${e['score'] ?? 0} pts',
            url: e['url'] ?? '',
            imageUrl: '',
            source: 'Hacker News',
            publishedAt: _fmtTs(e['time']),
          ));
        } catch (_) {}
      }
      return articles.where((a) => a.title.isNotEmpty).toList();
    } catch (_) { return []; }
  }
}
