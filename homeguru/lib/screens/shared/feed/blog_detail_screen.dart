import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'feed_models.dart';

class BlogDetailScreen extends StatelessWidget {
  const BlogDetailScreen({super.key, required this.blog});
  final HgBlog blog;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: blog.imageUrl.isNotEmpty ? 260 : 0,
            pinned: true,
            flexibleSpace: blog.imageUrl.isNotEmpty
                ? FlexibleSpaceBar(
                    background: CachedNetworkImage(
                      imageUrl: blog.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(color: cs.surfaceContainerHighest),
                      errorWidget: (_, _, _) => Container(color: cs.surfaceContainerHighest),
                    ),
                  )
                : null,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author row
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.verified_rounded, size: 12, color: cs.primary),
                        const SizedBox(width: 4),
                        Text('HomeGuru', style: tt.labelSmall?.copyWith(color: cs.onPrimaryContainer, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                    const SizedBox(width: 10),
                    if (blog.authorAvatar.isNotEmpty)
                      CircleAvatar(radius: 12, backgroundImage: NetworkImage(blog.authorAvatar), backgroundColor: cs.surfaceContainerHighest),
                    const SizedBox(width: 6),
                    Expanded(child: Text(blog.authorName, style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Text(blog.publishedAt, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ]),
                  const SizedBox(height: 16),

                  // Title
                  Text(blog.title, style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),

                  // Tags + read time
                  Row(children: [
                    ...blog.tags.map((t) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: cs.secondaryContainer, borderRadius: BorderRadius.circular(20)),
                        child: Text(t, style: tt.labelSmall?.copyWith(color: cs.onSecondaryContainer)),
                      ),
                    )),
                    if (blog.readTime.isNotEmpty) ...[
                      const Spacer(),
                      Icon(Icons.schedule_rounded, size: 14, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(blog.readTime, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ]),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),

                  // Rendered markdown body
                  MarkdownBody(
                    data: blog.body,
                    selectable: true,
                    onTapLink: (_, href, _) {
                      if (href != null) launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
                    },
                    styleSheet: MarkdownStyleSheet(
                      p: tt.bodyLarge?.copyWith(height: 1.8, color: cs.onSurface),
                      h1: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                      h2: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                      h3: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      blockquote: tt.bodyLarge?.copyWith(fontStyle: FontStyle.italic, color: cs.onSurfaceVariant),
                      blockquoteDecoration: BoxDecoration(
                        border: Border(left: BorderSide(width: 3, color: cs.tertiary)),
                        color: cs.tertiaryContainer.withValues(alpha: 0.2),
                      ),
                      code: tt.bodyMedium?.copyWith(fontFamily: 'monospace', backgroundColor: cs.surfaceContainerHighest),
                      codeblockDecoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      listBullet: tt.bodyLarge?.copyWith(color: cs.tertiary),
                      horizontalRuleDecoration: BoxDecoration(border: Border(top: BorderSide(color: cs.outlineVariant))),
                      a: TextStyle(color: cs.primary, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
