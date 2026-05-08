import 'package:flutter/material.dart';
import '../../shared/feed/feed_models.dart';
import '../../shared/feed/feed_widgets.dart';

class TutorFeedTab extends StatefulWidget {
  const TutorFeedTab({super.key});

  @override
  State<TutorFeedTab> createState() => _TutorFeedTabState();
}

class _TutorFeedTabState extends State<TutorFeedTab> with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: StoryRing(blogs: mockHgBlogs, isTutor: true),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: FeedTabDelegate(
              TabBar(
                controller: _tab,
                tabs: const [Tab(text: 'Blogs'), Tab(text: 'HG Shorts')],
                labelStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                unselectedLabelStyle: tt.labelLarge,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: cs.tertiary,
                dividerColor: cs.outlineVariant.withValues(alpha: 0.4),
              ),
              cs.surface,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tab,
          children: const [_BlogsView(isTutor: true), _NewsView(isTutor: true)],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add blog upload screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Blog upload coming soon!')),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Upload Blog'),
        backgroundColor: cs.tertiaryContainer,
        foregroundColor: cs.onTertiaryContainer,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

// ─── Blogs view ───────────────────────────────────────────────────────────────

class _BlogsView extends StatefulWidget {
  const _BlogsView({this.isTutor = false});
  final bool isTutor;

  @override
  State<_BlogsView> createState() => _BlogsViewState();
}

class _BlogsViewState extends State<_BlogsView>
    with AutomaticKeepAliveClientMixin, InfiniteScroll<_BlogsView> {
  final List<FeedArticle> _articles = [];
  bool _initialLoading = true;
  bool _error = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _articles.clear();
        page = 1;
        hasMore = true;
        _initialLoading = true;
        _error = false;
        FeedService.fetchBlogs(1);
      });
    }
    final result = await FeedService.fetchBlogs(page);
    if (!mounted) return;
    setState(() {
      _initialLoading = false;
      loadingMore = false;
      if (result.isEmpty) {
        hasMore = false;
      } else {
        _articles.addAll(result);
        page++;
      }
    });
  }

  @override
  void loadNextPage() {
    setState(() => loadingMore = true);
    _loadPage();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_initialLoading) return const FeedLoader();
    if (_error) return FeedError(onRetry: () => _loadPage(refresh: true));

    final hgBlogs = mockHgBlogs;
    int hgIdx = 0;
    int extIdx = 0;
    final items = <dynamic>[];

    while (extIdx < _articles.length || hgIdx < hgBlogs.length) {
      if (hgIdx < hgBlogs.length && items.length % 4 == 0) {
        items.add(hgBlogs[hgIdx++]);
      } else if (extIdx < _articles.length) {
        items.add(_articles[extIdx++]);
      } else {
        items.add(hgBlogs[hgIdx++]);
      }
    }

    return RefreshIndicator(
      onRefresh: () => _loadPage(refresh: true),
      child: ListView.separated(
        controller: scrollCtrl,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        itemCount: items.length + (loadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          if (i == items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final item = items[i];
          if (item is HgBlog) return HgBlogCard(blog: item, isTutor: widget.isTutor);
          return BlogCard(article: item as FeedArticle, isTutor: widget.isTutor);
        },
      ),
    );
  }
}

// ─── News view ────────────────────────────────────────────────────────────────

class _NewsView extends StatefulWidget {
  const _NewsView({this.isTutor = false});
  final bool isTutor;

  @override
  State<_NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<_NewsView>
    with AutomaticKeepAliveClientMixin, InfiniteScroll<_NewsView> {
  final List<FeedArticle> _articles = [];
  bool _initialLoading = true;
  bool _error = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _articles.clear();
        page = 1;
        hasMore = true;
        _initialLoading = true;
        _error = false;
        FeedService.hnIds = null;
      });
    }
    final result = await FeedService.fetchNews(page);
    if (!mounted) return;
    setState(() {
      _initialLoading = false;
      loadingMore = false;
      if (result.isEmpty) {
        hasMore = false;
      } else {
        _articles.addAll(result);
        page++;
      }
    });
  }

  @override
  void loadNextPage() {
    setState(() => loadingMore = true);
    _loadPage();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_initialLoading) return const FeedLoader();
    if (_error) return FeedError(onRetry: () => _loadPage(refresh: true));

    return RefreshIndicator(
      onRefresh: () => _loadPage(refresh: true),
      child: ListView.separated(
        controller: scrollCtrl,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        itemCount: _articles.length + (loadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, i) {
          if (i == _articles.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return NewsCard(article: _articles[i], isTutor: widget.isTutor);
        },
      ),
    );
  }
}
