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
  final String tutorId;
  final String readTime;

  const HgBlog({
    required this.id,
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.authorName,
    required this.authorAvatar,
    required this.tags,
    required this.publishedAt,
    this.tutorId = '',
    this.readTime = '',
  });

  factory HgBlog.fromJson(Map<String, dynamic> json) {
    return HgBlog(
      id: json['blogId'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      imageUrl: json['coverImageUrl'] ?? json['imageUrl'] ?? '',
      authorName: json['authorName'] ?? 'Tutor',
      authorAvatar: json['authorAvatar'] ?? '',
      tags: [json['tag'] ?? 'Education'],
      publishedAt: _formatDate(json['createdAt'] ?? ''),
      tutorId: json['tutorId'] ?? '',
      readTime: json['readTime'] ?? '',
    );
  }

  static String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}

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

  /// Fetch today's HG blogs (for stories ring)
  static Future<List<HgBlog>> fetchTodayBlogs() async {
    try {
      final res = await http.get(
        Uri.parse('https://app.homeguruworld.com/api/blogs?today=true'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return [];
      final data = json.decode(res.body);
      if (data['success'] != true) return [];
      final items = data['data'] as List? ?? [];
      return items.map((e) => HgBlog.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) { return []; }
  }

  /// Fetch all HG blogs
  static Future<List<HgBlog>> fetchAllBlogs({int limit = 20}) async {
    try {
      final res = await http.get(
        Uri.parse('https://app.homeguruworld.com/api/blogs?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return [];
      final data = json.decode(res.body);
      if (data['success'] != true) return [];
      final items = data['data'] as List? ?? [];
      return items.map((e) => HgBlog.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) { return []; }
  }

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
