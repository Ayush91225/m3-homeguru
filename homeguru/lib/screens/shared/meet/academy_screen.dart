import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class AcademyScreen extends StatefulWidget {
  final Function(String type, dynamic content)? onShareMedia;

  const AcademyScreen({super.key, this.onShareMedia});

  @override
  State<AcademyScreen> createState() => _AcademyScreenState();
}

class _AcademyScreenState extends State<AcademyScreen> {
  final _searchController = TextEditingController();
  String _activeQuery = 'science education';
  List<ImageResult> _images = [];
  bool _loading = true;
  String _sourceFilter = 'all';
  bool _showFilters = false;

  static const _categories = ['Biology', 'Physics', 'Chemistry', 'Space', 'Math', 'Geography', 'History', 'Art', 'Anatomy', 'Engineering', 'Nature', 'Technology'];
  static const _sources = [
    {'id': 'all', 'label': 'All'},
    {'id': 'wikimedia', 'label': 'Wikimedia'},
    {'id': 'openverse', 'label': 'Openverse'},
    {'id': 'unsplash', 'label': 'Unsplash'},
  ];

  @override
  void initState() {
    super.initState();
    _runSearch('science education');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _runSearch(String query) async {
    final trimmed = query.trim().isEmpty ? 'science education' : query.trim();
    setState(() {
      _activeQuery = trimmed;
      _loading = true;
    });

    final results = await _searchAll(trimmed, _sourceFilter);
    setState(() {
      _images = results;
      _loading = false;
    });
  }

  Future<List<ImageResult>> _searchAll(String query, String filter) async {
    final futures = <Future<List<ImageResult>>>[];
    
    if (filter == 'all' || filter == 'wikimedia') {
      futures.add(_searchWikimedia(query));
    }
    if (filter == 'all' || filter == 'openverse') {
      futures.add(_searchOpenverse(query));
    }
    if (filter == 'all' || filter == 'unsplash') {
      futures.add(_searchUnsplash(query));
    }

    final results = await Future.wait(futures);
    final all = <ImageResult>[];
    for (final list in results) {
      all.addAll(list);
    }

    if (filter == 'all') {
      all.shuffle();
    }

    return all;
  }

  Future<List<ImageResult>> _searchWikimedia(String query) async {
    try {
      final url = Uri.parse('https://commons.wikimedia.org/w/api.php').replace(queryParameters: {
        'action': 'query',
        'generator': 'search',
        'gsrnamespace': '6',
        'gsrsearch': '$query filetype:bitmap',
        'gsrlimit': '16',
        'prop': 'imageinfo',
        'iiprop': 'url|mime|extmetadata',
        'iiurlwidth': '400',
        'format': 'json',
        'origin': '*',
      });

      final response = await http.get(url);
      final data = json.decode(response.body);
      final pages = data['query']?['pages'];
      if (pages == null) return [];

      final results = <ImageResult>[];
      for (final page in pages.values) {
        final info = page['imageinfo']?[0];
        if (info == null || !(info['mime']?.toString().startsWith('image/') ?? false)) continue;

        results.add(ImageResult(
          id: 'wm-${page['pageid']}',
          url: info['url'],
          thumb: info['thumburl'] ?? info['url'],
          title: (page['title'] ?? '').replaceAll('File:', '').replaceAll(RegExp(r'\.[^.]+$'), ''),
          source: 'wikimedia',
          author: info['extmetadata']?['Artist']?['value']?.toString().replaceAll(RegExp(r'<[^>]*>'), '') ?? '',
          license: 'CC',
        ));
      }
      return results;
    } catch (e) {
      return [];
    }
  }

  Future<List<ImageResult>> _searchOpenverse(String query) async {
    try {
      final url = Uri.parse('https://api.openverse.org/v1/images/').replace(queryParameters: {
        'q': query,
        'page_size': '16',
        'license_type': 'commercial',
      });

      final response = await http.get(url);
      final data = json.decode(response.body);
      final items = data['results'] as List?;
      if (items == null) return [];

      return items.map((item) => ImageResult(
        id: 'ov-${item['id']}',
        url: item['url'],
        thumb: item['thumbnail'] ?? item['url'],
        title: item['title'] ?? 'Untitled',
        source: 'openverse',
        author: item['creator'] ?? '',
        license: item['license'] ?? 'CC',
      )).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ImageResult>> _searchUnsplash(String query) async {
    try {
      final results = <ImageResult>[];
      for (int i = 0; i < 8; i++) {
        results.add(ImageResult(
          id: 'us-$i-${DateTime.now().millisecondsSinceEpoch}',
          url: 'https://source.unsplash.com/800x600/?${Uri.encodeComponent(query)}&sig=$i',
          thumb: 'https://source.unsplash.com/400x300/?${Uri.encodeComponent(query)}&sig=$i',
          title: '$query #${i + 1}',
          source: 'unsplash',
          author: 'Unsplash',
          license: 'Free',
        ));
      }
      return results;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Academy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search images...',
                        hintStyle: TextStyle(fontSize: 13, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(fontSize: 13, color: cs.onSurface, fontWeight: FontWeight.w500),
                      onSubmitted: _runSearch,
                    ),
                  ),
                  if (_loading)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: SizedBox(
                        width: 14, height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: cs.secondary),
                      ),
                    )
                  else if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear, size: 12, color: cs.onSurfaceVariant),
                      onPressed: () {
                        _searchController.clear();
                        _runSearch('');
                      },
                    )
                  else
                    IconButton(
                      icon: Icon(Icons.refresh, size: 12, color: cs.onSurfaceVariant),
                      onPressed: () => _runSearch(_searchController.text),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final isActive = _activeQuery.toLowerCase() == cat.toLowerCase();
                return Material(
                  color: isActive ? cs.secondary : cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () {
                      _searchController.text = cat;
                      _runSearch(cat);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isActive ? cs.onSecondary : cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                InkWell(
                  onTap: () => setState(() => _showFilters = !_showFilters),
                  child: Row(
                    children: [
                      Icon(Icons.filter_list, size: 11, color: cs.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        '${_sources.firstWhere((s) => s['id'] == _sourceFilter)['label']} (${_images.length})',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showFilters)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Wrap(
                spacing: 6,
                children: _sources.map((s) {
                  final isActive = _sourceFilter == s['id'];
                  return Material(
                    color: isActive ? cs.secondary : cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _sourceFilter = s['id']!;
                          _showFilters = false;
                        });
                        _runSearch(_searchController.text.isEmpty ? _activeQuery : _searchController.text);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Text(
                          s['label']!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isActive ? cs.onSecondary : cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: _loading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.menu_book, size: 22, color: cs.secondary),
                        ),
                        const SizedBox(height: 12),
                        CircularProgressIndicator(color: cs.secondary),
                        const SizedBox(height: 12),
                        Text('Searching sources...', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
                : _images.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Icon(Icons.image_outlined, size: 22, color: cs.onSurfaceVariant),
                            ),
                            const SizedBox(height: 12),
                            Text('No images found', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text('Try a different search term', style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant)),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _images.length,
                        itemBuilder: (context, i) => _ImageCard(
                          image: _images[i],
                          onTap: () {
                            debugPrint('Image tapped: ${_images[i].url}');
                            debugPrint('onShareMedia callback: ${widget.onShareMedia}');
                            if (widget.onShareMedia != null) {
                              Navigator.pop(context);
                              Future.delayed(const Duration(milliseconds: 100), () {
                                widget.onShareMedia!('image', _images[i].url);
                              });
                            }
                          },
                        ),
                      ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.public, size: 10, color: cs.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text('Open-source images', style: TextStyle(fontSize: 8, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500)),
                  ],
                ),
                Text(_activeQuery, style: TextStyle(fontSize: 8, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final ImageResult image;
  final VoidCallback? onTap;

  const _ImageCard({required this.image, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sourceColor = image.source == 'wikimedia'
        ? cs.primary
        : image.source == 'openverse'
            ? cs.tertiary
            : cs.onSurfaceVariant;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: image.thumb,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: cs.surfaceContainerLow,
                          child: Center(
                            child: SizedBox(
                              width: 14, height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: cs.onSurfaceVariant),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(color: cs.surfaceContainerLow),
                      ),
                      Positioned(
                        top: 8, left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: sourceColor.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            image.source.toUpperCase(),
                            style: TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: cs.surface, letterSpacing: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      image.title,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: cs.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (image.author.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        image.author,
                        style: TextStyle(fontSize: 8, color: cs.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageResult {
  final String id;
  final String url;
  final String thumb;
  final String title;
  final String source;
  final String author;
  final String license;

  ImageResult({
    required this.id,
    required this.url,
    required this.thumb,
    required this.title,
    required this.source,
    required this.author,
    required this.license,
  });
}
