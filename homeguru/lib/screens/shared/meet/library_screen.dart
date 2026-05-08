import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _searchController = TextEditingController();
  List<ResearchPaper> _papers = [];
  bool _loading = false;
  ResearchPaper? _selectedPaper;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPapers(String query) async {
    if (query.trim().isEmpty) return;

    setState(() => _loading = true);

    try {
      // Using Semantic Scholar API
      final url = Uri.parse('https://api.semanticscholar.org/graph/v1/paper/search').replace(
        queryParameters: {
          'query': query,
          'limit': '20',
          'fields': 'title,authors,year,abstract,citationCount,publicationTypes,externalIds,url',
        },
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final papers = (data['data'] as List?)?.map((p) => ResearchPaper.fromJson(p)).toList() ?? [];
        setState(() => _papers = papers);
      }
    } catch (e) {
      debugPrint('Error searching papers: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_selectedPaper != null) {
      return _PaperViewer(
        paper: _selectedPaper!,
        onClose: () => setState(() => _selectedPaper = null),
      );
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Library', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search research papers...',
                prefixIcon: Icon(Icons.search, size: 20, color: cs.onSurfaceVariant),
                suffixIcon: _loading
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
                        ),
                      )
                    : null,
                filled: true,
                fillColor: cs.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                ),
              ),
              onSubmitted: _searchPapers,
            ),
          ),
          Expanded(
            child: _papers.isEmpty && !_loading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu_book, size: 48, color: cs.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text('Search for research papers', style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _papers.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _PaperCard(
                      paper: _papers[i],
                      onTap: () => setState(() => _selectedPaper = _papers[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PaperCard extends StatelessWidget {
  final ResearchPaper paper;
  final VoidCallback onTap;

  const _PaperCard({required this.paper, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (paper.citationCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: cs.tertiaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${paper.citationCount} citations',
                        style: TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: cs.tertiary),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    paper.year,
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                paper.title,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                paper.authors,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (paper.abstract.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  paper.abstract,
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PaperViewer extends StatelessWidget {
  final ResearchPaper paper;
  final VoidCallback onClose;

  const _PaperViewer({required this.paper, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: onClose,
        ),
        title: Text('Research Paper', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
        actions: [
          if (paper.url.isNotEmpty)
            IconButton(
              icon: Icon(Icons.open_in_new, size: 20, color: cs.primary),
              onPressed: () async {
                final uri = Uri.parse(paper.url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (paper.citationCount > 0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: cs.tertiaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${paper.citationCount} citations',
                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: cs.tertiary),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        paper.year,
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: cs.onPrimaryContainer),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    paper.title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onPrimaryContainer),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    paper.authors,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: cs.onPrimaryContainer.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Abstract
            if (paper.abstract.isNotEmpty) ...[
              Text(
                'ABSTRACT',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: cs.onSurface, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),
              Text(
                paper.abstract,
                style: TextStyle(fontSize: 13, color: cs.onSurface, height: 1.6),
              ),
              const SizedBox(height: 24),
            ],
            // Placeholder sections
            ...[
              {'title': '1. INTRODUCTION', 'content': 'This paper presents significant findings in the field. The research addresses key challenges and proposes novel solutions.'},
              {'title': '2. METHODOLOGY', 'content': 'The experimental setup involved comprehensive data collection and analysis using established protocols.'},
              {'title': '3. RESULTS', 'content': 'Findings demonstrate clear evidence supporting the hypothesis with statistical significance.'},
              {'title': '4. CONCLUSION', 'content': 'This work contributes to the field and opens avenues for future research.'},
            ].map((section) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section['title']!,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: cs.onSurface, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        section['content']!,
                        style: TextStyle(fontSize: 13, color: cs.onSurface, height: 1.6),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class ResearchPaper {
  final String id;
  final String title;
  final String authors;
  final String year;
  final String abstract;
  final int citationCount;
  final String url;

  ResearchPaper({
    required this.id,
    required this.title,
    required this.authors,
    required this.year,
    required this.abstract,
    required this.citationCount,
    required this.url,
  });

  factory ResearchPaper.fromJson(Map<String, dynamic> json) {
    final authors = (json['authors'] as List?)?.map((a) => a['name'] as String).join(', ') ?? 'Unknown';
    return ResearchPaper(
      id: json['paperId'] ?? '',
      title: json['title'] ?? 'Untitled',
      authors: authors,
      year: json['year']?.toString() ?? 'N/A',
      abstract: json['abstract'] ?? '',
      citationCount: json['citationCount'] ?? 0,
      url: json['url'] ?? '',
    );
  }
}
