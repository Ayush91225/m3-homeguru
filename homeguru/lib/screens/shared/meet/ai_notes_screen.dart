import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AINotesScreen extends StatefulWidget {
  const AINotesScreen({super.key});

  @override
  State<AINotesScreen> createState() => _AINotesScreenState();
}

class _AINotesScreenState extends State<AINotesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isDownloading = false;

  static const _transcript = [
    {'time': '00:15', 'speaker': 'Teacher', 'text': 'Welcome everyone. Today we are exploring modern web architecture.'},
    {'time': '01:22', 'speaker': 'Student', 'text': 'Will we be covering React Server Components?'},
    {'time': '01:45', 'speaker': 'Teacher', 'text': 'Yes, exactly. We\'ll look at how they improve performance.'},
    {'time': '05:10', 'speaker': 'Teacher', 'text': 'Notice how the data fetching happens on the server.'},
    {'time': '08:30', 'speaker': 'Teacher', 'text': 'Let\'s review the key points we\'ve discussed so far.'},
  ];

  static const _takeaways = [
    {'label': 'Performance', 'text': 'React Server Components enable server-side rendering, dramatically improving time-to-interactive.'},
    {'label': 'Data Fetching', 'text': 'Fetching happens server-side, close to the data source — reducing round-trip latency.'},
    {'label': 'Bundle Size', 'text': 'Server components are never shipped to the client, cutting JS payload significantly.'},
    {'label': 'Edge Delivery', 'text': 'Edge optimization ensures low-latency delivery across global networks.'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleDownload() async {
    setState(() => _isDownloading = true);

    await Future.delayed(const Duration(milliseconds: 600));

    final lines = [
      'HOMEGURU — AI STUDY NOTES',
      '=' * 40,
      '',
      'KEY INSIGHTS',
      '-' * 20,
      ..._takeaways.map((t) => '[${t['label']}]\n${t['text']}'),
      '',
      'TRANSCRIPT',
      '-' * 20,
      ..._transcript.map((t) => '[${t['time']}] ${t['speaker']!.toUpperCase()}\n${t['text']}'),
    ];

    final content = lines.join('\n\n');
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/OneOnOne_AI_Notes.txt');
    await file.writeAsString(content);

    await Share.shareXFiles([XFile(file.path)], text: 'AI Study Notes');

    setState(() => _isDownloading = false);
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
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: cs.tertiaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.psychology, size: 17, color: cs.tertiary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Study Notes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
                  Row(
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                          color: cs.tertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('AI POWERED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant, letterSpacing: 1.5)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _isDownloading ? null : _handleDownload,
            icon: _isDownloading
                ? SizedBox(
                    width: 14, height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: cs.onSurface),
                  )
                : Icon(Icons.download, size: 14, color: cs.onSurface),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      children: [
                        Text('${_takeaways.length}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface)),
                        const SizedBox(height: 2),
                        Text('INSIGHTS', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant, letterSpacing: 1.2)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      children: [
                        Text('${_transcript.length}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface)),
                        const SizedBox(height: 2),
                        Text('ENTRIES', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant, letterSpacing: 1.2)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5))),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: cs.tertiary,
              unselectedLabelColor: cs.onSurfaceVariant,
              indicatorColor: cs.tertiary,
              labelStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 1.2),
              tabs: const [
                Tab(text: 'INSIGHTS'),
                Tab(text: 'TRANSCRIPT'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInsightsTab(cs),
                _buildTranscriptTab(cs),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.psychology, size: 11, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Text('POWERED BY OSMIUM AI', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant, letterSpacing: 1.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(ColorScheme cs) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.tertiaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.tertiary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, size: 13, color: cs.tertiary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Session focused on server-side rendering with RSC — performance, bundle size, and edge delivery.',
                  style: TextStyle(fontSize: 10, color: cs.onSurface, fontWeight: FontWeight.w500, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ..._takeaways.asMap().entries.map((entry) {
          final i = entry.key;
          final t = entry.value;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: i < _takeaways.length - 1
                    ? BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5))
                    : BorderSide.none,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    color: cs.tertiary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}'.padLeft(2, '0'),
                    style: TextStyle(fontSize: 7, fontWeight: FontWeight.w600, color: cs.onTertiary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t['label']!.toUpperCase(),
                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t['text']!,
                        style: TextStyle(fontSize: 12, color: cs.onSurface, fontWeight: FontWeight.w500, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTranscriptTab(ColorScheme cs) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _transcript.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, i) {
        final entry = _transcript[i];
        final isTeacher = entry['speaker'] == 'Teacher';

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: isTeacher ? cs.tertiary : cs.surfaceContainerLow,
                shape: BoxShape.circle,
                border: isTeacher ? null : Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
              ),
              alignment: Alignment.center,
              child: Icon(
                isTeacher ? Icons.school : Icons.person,
                size: 11,
                color: isTeacher ? cs.onTertiary : cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        entry['speaker']!.toUpperCase(),
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: cs.onSurface, letterSpacing: 0.5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry['time']!,
                        style: TextStyle(fontSize: 8, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry['text']!,
                    style: TextStyle(fontSize: 12, color: cs.onSurface, fontWeight: FontWeight.w500, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
