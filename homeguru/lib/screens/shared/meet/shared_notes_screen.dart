import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/meeting_signaling_service.dart';

class SharedNotesScreen extends StatefulWidget {
  final MeetingSignalingService? signalingService;

  const SharedNotesScreen({super.key, this.signalingService});

  @override
  State<SharedNotesScreen> createState() => _SharedNotesScreenState();
}

class _SharedNotesScreenState extends State<SharedNotesScreen> {
  List<NotePage> _pages = [];
  String _activeId = '';
  bool _saving = false;
  bool _saved = false;
  bool _editingTitle = false;
  bool _copied = false;
  final _textController = TextEditingController();
  final _titleController = TextEditingController();
  bool _isRemoteUpdate = false;

  static const _storageKey = 'oneonone_notes_v2';

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _listenToSignaling();
  }

  @override
  void dispose() {
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_storageKey);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List;
        setState(() {
          _pages = list.map((e) => NotePage.fromJson(e)).toList();
          _activeId = _pages.isNotEmpty ? _pages[0].id : '';
          _updateControllers();
        });
        return;
      } catch (e) {
        debugPrint('Error loading notes: $e');
      }
    }
    setState(() {
      _pages = [NotePage(id: DateTime.now().toString(), title: 'Session Notes', content: '', updatedAt: DateTime.now())];
      _activeId = _pages[0].id;
      _updateControllers();
    });
  }

  void _listenToSignaling() {
    widget.signalingService?.messages.listen((msg) {
      if (msg['action'] == 'notes-sync' && msg['content'] != null) {
        try {
          final list = jsonDecode(msg['content']) as List;
          _isRemoteUpdate = true;
          setState(() {
            _pages = list.map((e) => NotePage.fromJson(e)).toList();
            _updateControllers();
          });
          _isRemoteUpdate = false;
        } catch (e) {
          debugPrint('Error syncing notes: $e');
        }
      }
    });
  }

  void _updateControllers() {
    final page = _pages.firstWhere((p) => p.id == _activeId, orElse: () => _pages.first);
    _textController.text = page.content;
    _titleController.text = page.title;
  }

  Future<void> _persist() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_pages.map((p) => p.toJson()).toList()));
    if (mounted) {
      setState(() {
        _saving = false;
        _saved = true;
      });
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _saved = false);
      });
    }
  }

  void _updatePage(String id, {String? title, String? content}) {
    setState(() {
      final index = _pages.indexWhere((p) => p.id == id);
      if (index != -1) {
        _pages[index] = NotePage(
          id: id,
          title: title ?? _pages[index].title,
          content: content ?? _pages[index].content,
          updatedAt: DateTime.now(),
        );
      }
    });
    _persist();
    if (!_isRemoteUpdate && content != null) {
      widget.signalingService?.send({
        'action': 'notes-sync',
        'content': jsonEncode(_pages.map((p) => p.toJson()).toList()),
      });
    }
  }

  void _addPage() {
    final page = NotePage(
      id: DateTime.now().toString(),
      title: 'Page ${_pages.length + 1}',
      content: '',
      updatedAt: DateTime.now(),
    );
    setState(() {
      _pages.add(page);
      _activeId = page.id;
      _updateControllers();
    });
    _persist();
  }

  void _deletePage(String id) {
    if (_pages.length == 1) return;
    setState(() {
      _pages.removeWhere((p) => p.id == id);
      if (_activeId == id) {
        _activeId = _pages.first.id;
        _updateControllers();
      }
    });
    _persist();
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final activePage = _pages.firstWhere((p) => p.id == _activeId, orElse: () => _pages.first);
    final words = activePage.content.trim().isEmpty ? 0 : activePage.content.trim().split(RegExp(r'\s+')).length;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Shared Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _pages.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 4),
                      itemBuilder: (context, i) {
                        final page = _pages[i];
                        final isActive = page.id == _activeId;
                        return Material(
                          color: isActive ? cs.primary : cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _activeId = page.id;
                                _updateControllers();
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.description, size: 10, color: isActive ? cs.onPrimary : cs.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(
                                    page.title,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: isActive ? cs.onPrimary : cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: cs.surfaceContainerLow,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: _addPage,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 28, height: 28,
                      alignment: Alignment.center,
                      child: Icon(Icons.add, size: 12, color: cs.onSurfaceVariant),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Title & Actions
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _editingTitle
                          ? TextField(
                              controller: _titleController,
                              autofocus: true,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface),
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(borderSide: BorderSide(color: cs.primary)),
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onSubmitted: (v) {
                                _updatePage(_activeId, title: v);
                                setState(() => _editingTitle = false);
                              },
                            )
                          : GestureDetector(
                              onTap: () => setState(() => _editingTitle = true),
                              child: Row(
                                children: [
                                  Text(
                                    activePage.title,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(Icons.edit, size: 10, color: cs.onSurfaceVariant),
                                ],
                              ),
                            ),
                    ),
                    IconButton(
                      icon: Icon(_copied ? Icons.check : Icons.copy, size: 11, color: _copied ? cs.tertiary : cs.onSurfaceVariant),
                      onPressed: () {
                        // TODO: Copy to clipboard
                        setState(() => _copied = true);
                        Future.delayed(const Duration(milliseconds: 1500), () {
                          if (mounted) setState(() => _copied = false);
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    ),
                    if (_pages.length > 1)
                      IconButton(
                        icon: Icon(Icons.delete_outline, size: 11, color: cs.error),
                        onPressed: () => _deletePage(_activeId),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 9, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(_timeAgo(activePage.updatedAt), style: TextStyle(fontSize: 8, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 8),
                    Text('·', style: TextStyle(fontSize: 8, color: cs.outlineVariant)),
                    const SizedBox(width: 8),
                    Text('$words words', style: TextStyle(fontSize: 8, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500)),
                    const Spacer(),
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _saving ? cs.primary : cs.tertiary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _saving ? 'SAVING' : _saved ? 'SAVED' : 'SYNCED',
                      style: TextStyle(fontSize: 7, color: cs.onSurfaceVariant, fontWeight: FontWeight.w700, letterSpacing: 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Editor
          Expanded(
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              style: TextStyle(fontSize: 13, color: cs.onSurface, fontWeight: FontWeight.w500, height: 1.9),
              decoration: InputDecoration(
                hintText: 'Start typing your notes…\n\nNotes sync to all participants',
                hintStyle: TextStyle(fontSize: 13, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: (v) => _updatePage(_activeId, content: v),
            ),
          ),
        ],
      ),
    );
  }
}

class NotePage {
  final String id;
  final String title;
  final String content;
  final DateTime updatedAt;

  NotePage({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  factory NotePage.fromJson(Map<String, dynamic> json) => NotePage(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
      );
}
