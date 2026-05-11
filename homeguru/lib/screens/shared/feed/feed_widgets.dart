import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'feed_models.dart';
import 'blog_detail_screen.dart';
import 'webview_screen.dart';

// ─── Infinite-scroll mixin ────────────────────────────────────────────────────

mixin InfiniteScroll<T extends StatefulWidget> on State<T> {
  final scrollCtrl = ScrollController();
  bool loadingMore = false;
  bool hasMore = true;
  int page = 1;

  @override
  void initState() {
    super.initState();
    scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!hasMore || loadingMore) return;
    if (scrollCtrl.position.pixels >= scrollCtrl.position.maxScrollExtent - 200) {
      loadNextPage();
    }
  }

  void loadNextPage();
}

// ─── Story ring ───────────────────────────────────────────────────────────────

/// Groups blogs by authorName and shows one ring per unique author.
/// Tapping opens StoryViewerScreen with all that author's blogs.
class StoryRing extends StatelessWidget {
  const StoryRing({super.key, required this.blogs, this.isTutor = false});
  final List<HgBlog> blogs;
  final bool isTutor;

  @override
  Widget build(BuildContext context) {
    if (blogs.isEmpty) {
      final cs = Theme.of(context).colorScheme;
      final tt = Theme.of(context).textTheme;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(Icons.auto_stories_outlined, size: 28, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
              const SizedBox(height: 6),
              Text('No stories yet', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accentColor = isTutor ? cs.tertiary : cs.primary;

    // Group by author, preserving first-seen order
    final Map<String, List<HgBlog>> grouped = {};
    for (final b in blogs) {
      grouped.putIfAbsent(b.authorName, () => []).add(b);
    }
    final authors = grouped.keys.toList();

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: authors.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final name = authors[i];
          final authorBlogs = grouped[name]!;
          final avatar = authorBlogs.first.authorAvatar;
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StoryViewerScreen(blogs: authorBlogs),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [accentColor, cs.tertiary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundImage: NetworkImage(avatar),
                      backgroundColor: cs.surfaceContainerHighest,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 62,
                  child: Text(
                    name.split(' ').first,
                    style: tt.labelSmall,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Story viewer ─────────────────────────────────────────────────────────────

class StoryViewerScreen extends StatefulWidget {
  const StoryViewerScreen({super.key, required this.blogs});
  final List<HgBlog> blogs;

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  int _current = 0;
  late AnimationController _timer;
  static const _duration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _timer = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _next();
      })
      ..forward();
  }

  @override
  void dispose() {
    _timer.dispose();
    super.dispose();
  }

  void _next() {
    if (_current < widget.blogs.length - 1) {
      setState(() => _current++);
      _timer
        ..reset()
        ..forward();
    } else {
      Navigator.pop(context);
    }
  }

  void _prev() {
    if (_current > 0) {
      setState(() => _current--);
      _timer
        ..reset()
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final blog = widget.blogs[_current];
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final total = widget.blogs.length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (d) {
          final x = d.globalPosition.dx;
          final w = MediaQuery.of(context).size.width;
          if (x < w / 3) {
            _prev();
          } else {
            _next();
          }
        },
        onLongPressStart: (_) => _timer.stop(),
        onLongPressEnd: (_) => _timer.forward(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            CachedNetworkImage(
              imageUrl: blog.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: Colors.black),
              errorWidget: (_, _, _) => Container(color: Colors.black87),
            ),
            // Dark gradient top + bottom
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
            ),
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
            // Progress bars
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              right: 12,
              child: Row(
                children: List.generate(total, (i) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: i < _current
                            ? Container(height: 3, color: Colors.white)
                            : i == _current
                                ? AnimatedBuilder(
                                    animation: _timer,
                                    builder: (_, _) => LinearProgressIndicator(
                                      value: _timer.value,
                                      minHeight: 3,
                                      backgroundColor:
                                          Colors.white.withValues(alpha: 0.35),
                                      valueColor:
                                          const AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : Container(
                                    height: 3,
                                    color: Colors.white.withValues(alpha: 0.35),
                                  ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Author row
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 16,
              right: 48,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(blog.authorAvatar),
                    backgroundColor: Colors.white24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(blog.authorName,
                            style: tt.labelMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                        Text(blog.publishedAt,
                            style: tt.labelSmall
                                ?.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Close button
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 12,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Bottom content
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    children: blog.tags
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(t,
                                  style: tt.labelSmall
                                      ?.copyWith(color: Colors.white)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(blog.title,
                      style: tt.titleMedium?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => BlogDetailScreen(blog: blog)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text('Read more',
                          style: tt.labelMedium?.copyWith(
                              color: cs.onPrimary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Blog card (external dev.to) ─────────────────────────────────────────────

class BlogCard extends StatelessWidget {
  const BlogCard({super.key, required this.article, this.isTutor = false});
  final FeedArticle article;
  final bool isTutor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accentColor = isTutor ? cs.tertiary : cs.primary;

    return InkWell(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => WebViewScreen(url: article.url, title: article.source))),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: article.imageUrl,
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(height: 170, color: cs.surfaceContainerHighest),
                errorWidget: (_, _, _) => const SizedBox.shrink(),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.title,
                      style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  if (article.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(article.description,
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(article.source,
                            style: tt.labelSmall?.copyWith(color: accentColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (article.publishedAt.isNotEmpty)
                        Text(article.publishedAt,
                            style: tt.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── HG Blog card ─────────────────────────────────────────────────────────────

class HgBlogCard extends StatelessWidget {
  const HgBlogCard({super.key, required this.blog, this.isTutor = false});
  final HgBlog blog;
  final bool isTutor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accentColor = isTutor ? cs.tertiary : cs.primary;
    final accentContainer = isTutor ? cs.tertiaryContainer : cs.primaryContainer;
    final onAccentContainer = isTutor ? cs.onTertiaryContainer : cs.onPrimaryContainer;

    return InkWell(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => BlogDetailScreen(blog: blog))),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: blog.imageUrl,
              height: 170,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, _) =>
                  Container(height: 170, color: cs.surfaceContainerHighest),
              errorWidget: (_, _, _) =>
                  Container(height: 170, color: cs.surfaceContainerHighest),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HomeGuru badge + author
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded,
                                size: 11, color: accentColor),
                            const SizedBox(width: 3),
                            Text('HomeGuru',
                                style: tt.labelSmall?.copyWith(
                                    color: onAccentContainer,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 10,
                        backgroundImage: NetworkImage(blog.authorAvatar),
                        backgroundColor: cs.surfaceContainerHighest,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(blog.authorName,
                            style: tt.labelSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text(blog.publishedAt,
                          style: tt.labelSmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(blog.title,
                      style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  // Tags
                  Wrap(
                    spacing: 6,
                    children: blog.tags
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isTutor ? cs.tertiaryContainer : cs.secondaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(t,
                                  style: tt.labelSmall?.copyWith(
                                      color: isTutor ? cs.onTertiaryContainer : cs.onSecondaryContainer)),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── News card ────────────────────────────────────────────────────────────────

class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.article, this.isTutor = false});
  final FeedArticle article;
  final bool isTutor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accentContainer = isTutor ? cs.tertiaryContainer : cs.primaryContainer;
    final onAccentContainer = isTutor ? cs.onTertiaryContainer : cs.onPrimaryContainer;
    final seed = article.title.hashCode.abs() % 1000;
    final imgUrl = article.imageUrl.isNotEmpty
        ? article.imageUrl
        : 'https://picsum.photos/seed/$seed/400/200';

    return InkWell(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => WebViewScreen(url: article.url, title: article.source))),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: imgUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, _) =>
                  Container(height: 150, color: cs.surfaceContainerHighest),
              errorWidget: (_, _, _) =>
                  Container(height: 150, color: cs.surfaceContainerHighest,
                    child: Center(child: Icon(Icons.image_outlined, color: cs.onSurfaceVariant.withValues(alpha: 0.3), size: 32))),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.title,
                      style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis),
                  if (article.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(article.description,
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(article.source,
                            style: tt.labelSmall?.copyWith(
                                color: onAccentContainer,
                                fontWeight: FontWeight.w600)),
                      ),
                      if (article.publishedAt.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(article.publishedAt,
                            style:
                                tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared: loader, error, tab delegate ─────────────────────────────────────

class FeedLoader extends StatelessWidget {
  const FeedLoader({super.key});
  @override
  Widget build(_) => const Center(child: CircularProgressIndicator());
}

class FeedError extends StatelessWidget {
  const FeedError({super.key, required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 48, color: cs.onSurfaceVariant),
          const SizedBox(height: 12),
          Text('Could not load. Pull to retry.',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 16),
          FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class FeedTabDelegate extends SliverPersistentHeaderDelegate {
  const FeedTabDelegate(this.tabBar, this.color);
  final TabBar tabBar;
  final Color color;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(_, _, _) => ColoredBox(color: color, child: tabBar);

  @override
  bool shouldRebuild(FeedTabDelegate old) => old.tabBar != tabBar;
}
