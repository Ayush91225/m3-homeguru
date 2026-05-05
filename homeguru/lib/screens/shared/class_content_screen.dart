import 'package:flutter/material.dart';
import 'class_content/cc_shared.dart';
import 'class_content/cc_rec.dart';
import 'class_content/cc_transcript_notes.dart';
import 'class_content/cc_chats_files.dart';
import 'class_content/cc_quiz_polls.dart';
import 'class_content/cc_flashcards.dart';

class ClassContentScreen extends StatefulWidget {
  final Map<String, dynamic> session;
  const ClassContentScreen({super.key, required this.session});

  @override
  State<ClassContentScreen> createState() => _ClassContentScreenState();
}

class _ClassContentScreenState extends State<ClassContentScreen> {
  final _scrollController = ScrollController();
  final _chipScrollController = ScrollController();

  final Map<ClassSection, GlobalKey> _keys = {
    for (final s in ClassSection.values) s: GlobalKey(),
  };

  ClassSection _activeChip = ClassSection.rec;
  bool _programmaticScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _chipScrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_programmaticScroll) return;
    ClassSection? best;
    double bestOffset = double.infinity;

    for (final s in ClassSection.values) {
      final ctx = _keys[s]!.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final dy = box.localToGlobal(Offset.zero).dy;
      // pick the section whose top is closest to but still above 140px from top
      if (dy <= 140 && (140 - dy) < bestOffset) {
        bestOffset = 140 - dy;
        best = s;
      }
    }

    if (best != null && best != _activeChip) {
      setState(() => _activeChip = best!);
      _scrollChipIntoView(best);
    }
  }

  void _scrollChipIntoView(ClassSection s) {
    final idx = ClassSection.values.indexOf(s);
    // approximate chip width ~100px, scroll to keep it visible
    _chipScrollController.animateTo(
      (idx * 108.0).clamp(0, _chipScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _scrollTo(ClassSection section) async {
    final ctx = _keys[section]!.currentContext;
    if (ctx == null) return;
    _programmaticScroll = true;
    setState(() => _activeChip = section);
    _scrollChipIntoView(section);
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    await Future.delayed(const Duration(milliseconds: 450));
    _programmaticScroll = false;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final session = widget.session;

    return Scaffold(
      backgroundColor: cs.surface,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: cs.surface,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session['title'] ?? 'Class Content',
                  style: tt.titleMedium?.copyWith(color: cs.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  session['subject'] ?? '',
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: _ChipBar(
                active: _activeChip,
                scrollController: _chipScrollController,
                onTap: _scrollTo,
              ),
            ),
          ),
        ],
        body: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            RecSection(key: _keys[ClassSection.rec], session: session),
            TranscriptSection(key: _keys[ClassSection.transcript]),
            AiNotesSection(key: _keys[ClassSection.aiNotes]),
            ChatsSection(key: _keys[ClassSection.chats]),
            FilesSection(key: _keys[ClassSection.files], session: session),
            QuizSection(key: _keys[ClassSection.quiz], session: session),
            PollsSection(key: _keys[ClassSection.polls]),
            FlashcardsSection(key: _keys[ClassSection.flashcards]),
          ],
        ),
      ),
    );
  }
}

// ── Chip bar ──────────────────────────────────────────────────────────────────

class _ChipBar extends StatelessWidget {
  final ClassSection active;
  final ScrollController scrollController;
  final void Function(ClassSection) onTap;

  const _ChipBar({
    required this.active,
    required this.scrollController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 52,
      child: ListView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: ClassSection.values.map((s) {
          final selected = s == active;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: selected,
              showCheckmark: false,
              avatar: Icon(
                sectionIcons[s],
                size: 16,
                color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
              label: Text(sectionLabels[s]!),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
              backgroundColor: cs.surfaceContainerLow,
              selectedColor: cs.primaryContainer,
              side: BorderSide.none,
              shape: const StadiumBorder(),
              onSelected: (_) => onTap(s),
            ),
          );
        }).toList(),
      ),
    );
  }
}
