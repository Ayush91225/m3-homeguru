import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/blog_service.dart';
import '../../../../services/tutor_profile_service.dart';

class BlogEditorScreen extends StatefulWidget {
  const BlogEditorScreen({super.key});

  @override
  State<BlogEditorScreen> createState() => _BlogEditorScreenState();
}

class _BlogEditorScreenState extends State<BlogEditorScreen> {
  final _titleCtrl = TextEditingController();
  late final QuillController _quill;
  final _scrollCtrl = ScrollController();
  final _editorScrollCtrl = ScrollController();
  final _editorFocus = FocusNode();
  String _tag = 'Education';
  File? _coverImage;
  bool _publishing = false;

  static const _tags = [
    'Education', 'Mathematics', 'Physics', 'Science',
    'Teaching', 'Study Tips', 'Personal', 'EdTech',
    'Chemistry', 'Biology', 'English', 'History',
  ];

  @override
  void initState() {
    super.initState();
    _quill = QuillController.basic();
    _quill.addListener(_onChanged);
    _titleCtrl.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _titleCtrl.dispose();
    _quill.dispose();
    _scrollCtrl.dispose();
    _editorScrollCtrl.dispose();
    _editorFocus.dispose();
    super.dispose();
  }

  String get _plainText => _quill.document.toPlainText().trim();
  int get _wordCount => _plainText.isEmpty ? 0 : _plainText.split(RegExp(r'\s+')).length;
  String get _readTime {
    final m = (_wordCount / 200).ceil();
    return m < 1 ? '<1 min' : '$m min read';
  }

  bool get _canPublish => _titleCtrl.text.trim().isNotEmpty && _wordCount > 10;
  bool get _hasContent => _titleCtrl.text.trim().isNotEmpty || _plainText.isNotEmpty || _coverImage != null;

  // ─── Actions ──────────────────────────────────────────────────────────

  Future<bool> _onBack() async {
    if (!_hasContent) return true;
    final cs = Theme.of(context).colorScheme;
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard draft?'),
        content: const Text('You have unsaved changes that will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep editing')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onError),
            child: const Text('Discard'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _pickCover() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.photo_library_outlined), title: const Text('Gallery'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
          ListTile(leading: const Icon(Icons.camera_alt_outlined), title: const Text('Camera'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera)),
        ]),
      ),
    );
    if (source == null) return;
    final xfile = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 85);
    if (xfile != null && mounted) setState(() => _coverImage = File(xfile.path));
  }

  void _insertImage() async {
    final xfile = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 80);
    if (xfile != null && mounted) {
      final idx = _quill.selection.baseOffset;
      _quill.document.insert(idx, BlockEmbed.image(xfile.path));
      _quill.updateSelection(TextSelection.collapsed(offset: idx + 1), ChangeSource.local);
    }
  }

  void _showTagPicker() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Select Tag', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, children: _tags.map((t) {
              final sel = _tag == t;
              return GestureDetector(
                onTap: () { setState(() => _tag = t); Navigator.pop(ctx); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? cs.tertiary : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: sel ? null : Border.all(color: cs.outlineVariant),
                  ),
                  child: Text(t, style: tt.labelMedium?.copyWith(
                    color: sel ? cs.onTertiary : cs.onSurface,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                  )),
                ),
              );
            }).toList()),
          ]),
        ),
      ),
    );
  }

  Future<void> _publish() async {
    if (!_canPublish) return;
    HapticFeedback.mediumImpact();
    setState(() => _publishing = true);

    final prefs = await SharedPreferences.getInstance();
    final tutorId = prefs.getString('userId');
    if (tutorId == null) {
      setState(() => _publishing = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not logged in')));
      return;
    }

    final profileResult = await TutorProfileService.getTutorProfile(tutorId);
    String authorName = 'Tutor';
    String authorAvatar = '';
    if (profileResult['success'] == true) {
      final data = profileResult['data'] as Map<String, dynamic>;
      authorName = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
      authorAvatar = data['profilePhoto']?.toString() ?? '';
    }

    final result = await BlogService.publish(
      tutorId: tutorId,
      title: _titleCtrl.text.trim(),
      body: _plainText,
      tag: _tag,
      coverImagePath: _coverImage?.path,
      authorName: authorName,
      authorAvatar: authorAvatar,
    );

    if (mounted) {
      setState(() => _publishing = false);
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Blog published! 🎉'), backgroundColor: Theme.of(context).colorScheme.tertiary),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['error'] ?? 'Failed to publish')));
      }
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return PopScope(
      canPop: !_hasContent,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final go = await _onBack();
          if (go && mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        body: Column(children: [
          // ── App Bar ──
          Container(
            padding: EdgeInsets.fromLTRB(8, MediaQuery.of(context).padding.top + 4, 8, 8),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
            ),
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () async {
                  if (!_hasContent) { Navigator.pop(context); return; }
                  final go = await _onBack();
                  if (go && mounted) Navigator.of(context).pop();
                },
              ),
              if (_wordCount > 0)
                Text('$_wordCount words · $_readTime', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              const Spacer(),
              // Tag chip
              GestureDetector(
                onTap: _showTagPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: cs.tertiaryContainer, borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(_tag, style: tt.labelSmall?.copyWith(color: cs.onTertiaryContainer, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 2),
                    Icon(Icons.expand_more_rounded, size: 14, color: cs.onTertiaryContainer),
                  ]),
                ),
              ),
              const SizedBox(width: 8),
              // Publish button
              FilledButton(
                onPressed: _canPublish && !_publishing ? _publish : null,
                style: FilledButton.styleFrom(
                  backgroundColor: cs.tertiary, foregroundColor: cs.onTertiary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: _publishing
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Publish'),
              ),
            ]),
          ),

          // ── Editor body ──
          Expanded(
            child: ListView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              children: [
                // Cover image
                if (_coverImage != null)
                  Stack(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(_coverImage!, width: double.infinity, height: 180, fit: BoxFit.cover),
                    ),
                    Positioned(top: 8, right: 8, child: GestureDetector(
                      onTap: () => setState(() => _coverImage = null),
                      child: Container(
                        width: 28, height: 28,
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                      ),
                    )),
                  ])
                else
                  GestureDetector(
                    onTap: _pickCover,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.panorama_outlined, size: 18, color: cs.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text('Add cover image', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                      ]),
                    ),
                  ),
                const SizedBox(height: 16),

                // Title
                TextField(
                  controller: _titleCtrl,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
                  decoration: InputDecoration(
                    hintText: 'Title',
                    hintStyle: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: cs.onSurfaceVariant.withValues(alpha: 0.35)),
                    border: InputBorder.none, contentPadding: EdgeInsets.zero,
                  ),
                ),
                Divider(height: 24, color: cs.outlineVariant.withValues(alpha: 0.25)),

                // Quill editor — WYSIWYG, no raw markdown
                QuillEditor(
                  controller: _quill,
                  focusNode: _editorFocus,
                  scrollController: _editorScrollCtrl,
                  config: QuillEditorConfig(
                    placeholder: 'Tell your story...',
                    padding: EdgeInsets.zero,
                    autoFocus: false,
                    expands: false,
                    scrollable: false,
                    embedBuilders: [_ImageEmbedBuilder()],
                    customStyles: DefaultStyles(
                      paragraph: DefaultTextBlockStyle(
                        tt.bodyLarge!.copyWith(height: 1.8, color: cs.onSurface),
                        HorizontalSpacing.zero, VerticalSpacing(0, 0), VerticalSpacing.zero, null,
                      ),
                      h1: DefaultTextBlockStyle(
                        tt.headlineSmall!.copyWith(fontWeight: FontWeight.w800, color: cs.onSurface),
                        HorizontalSpacing.zero, VerticalSpacing(16, 8), VerticalSpacing.zero, null,
                      ),
                      h2: DefaultTextBlockStyle(
                        tt.titleLarge!.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface),
                        HorizontalSpacing.zero, VerticalSpacing(12, 6), VerticalSpacing.zero, null,
                      ),
                      h3: DefaultTextBlockStyle(
                        tt.titleMedium!.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface),
                        HorizontalSpacing.zero, VerticalSpacing(8, 4), VerticalSpacing.zero, null,
                      ),
                      quote: DefaultTextBlockStyle(
                        tt.bodyLarge!.copyWith(fontStyle: FontStyle.italic, color: cs.onSurfaceVariant, height: 1.6),
                        HorizontalSpacing.zero, VerticalSpacing(8, 8), VerticalSpacing.zero,
                        BoxDecoration(border: Border(left: BorderSide(color: cs.tertiary, width: 3))),
                      ),
                      code: DefaultTextBlockStyle(
                        tt.bodyMedium!.copyWith(fontFamily: 'monospace', color: cs.onSurface, height: 1.5),
                        HorizontalSpacing.zero, VerticalSpacing(8, 8), VerticalSpacing.zero,
                        BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                      ),
                      bold: const TextStyle(fontWeight: FontWeight.w700),
                      italic: const TextStyle(fontStyle: FontStyle.italic),
                      strikeThrough: const TextStyle(decoration: TextDecoration.lineThrough),
                      link: TextStyle(color: cs.primary, decoration: TextDecoration.underline),
                      placeHolder: DefaultTextBlockStyle(
                        tt.bodyLarge!.copyWith(color: cs.onSurfaceVariant.withValues(alpha: 0.35), height: 1.8),
                        HorizontalSpacing.zero, VerticalSpacing.zero, VerticalSpacing.zero, null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Toolbar ──
          Container(
            padding: EdgeInsets.fromLTRB(0, 4, 0, MediaQuery.of(context).padding.bottom + 4),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
            ),
            child: Row(children: [
              // Insert image
              IconButton(
                onPressed: _insertImage,
                icon: Icon(Icons.add_photo_alternate_outlined, size: 20, color: cs.onSurfaceVariant),
                tooltip: 'Insert image',
              ),
              // Quill toolbar
              Expanded(
                child: QuillSimpleToolbar(
                  controller: _quill,
                  config: QuillSimpleToolbarConfig(
                    showAlignmentButtons: false,
                    showBackgroundColorButton: false,
                    showCenterAlignment: false,
                    showClearFormat: false,
                    showColorButton: false,
                    showDirection: false,
                    showFontFamily: false,
                    showFontSize: false,
                    showIndent: false,
                    showInlineCode: true,
                    showJustifyAlignment: false,
                    showLeftAlignment: false,
                    showRightAlignment: false,
                    showSearchButton: false,
                    showSmallButton: false,
                    showSubscript: false,
                    showSuperscript: false,
                    showUndo: true,
                    showRedo: true,
                    multiRowsDisplay: false,
                    toolbarSize: 40,
                    buttonOptions: QuillSimpleToolbarButtonOptions(
                      base: QuillToolbarBaseButtonOptions(
                        iconTheme: QuillIconTheme(
                          iconButtonSelectedData: IconButtonData(
                            color: cs.onTertiary,
                            style: IconButton.styleFrom(backgroundColor: cs.tertiary),
                          ),
                          iconButtonUnselectedData: IconButtonData(color: cs.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Renders inline images in the Quill editor
class _ImageEmbedBuilder extends EmbedBuilder {
  @override
  String get key => BlockEmbed.imageType;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final src = embedContext.node.value.data as String;
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: src.startsWith('http')
          ? Image.network(src, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _placeholder(cs))
          : Image.file(File(src), width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _placeholder(cs)),
    );
  }

  Widget _placeholder(ColorScheme cs) => Container(
    height: 160, color: cs.surfaceContainerHighest,
    child: Center(child: Icon(Icons.image_outlined, size: 28, color: cs.onSurfaceVariant.withValues(alpha: 0.4))),
  );
}
