import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'chat_models.dart';
import 'chat_widgets.dart';
import 'conversation_screen.dart';

export 'chat_models.dart' show ChatTutor, ChatMessage;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _tabIndex = 0;
  String _search = '';
  final _searchCtrl = TextEditingController();

  late final List<ChatTutor> _inbox = List.of(seedInbox);
  late final List<ChatTutor> _past = List.of(seedPast);
  late final List<ChatTutor> _archived = List.of(seedArchived);

  final Map<String, List<ChatMessage>> _messages = {};
  List<ChatMessage> _msgsFor(String id) =>
      _messages.putIfAbsent(id, () => []);

  static const _sections = ['Inbox', 'Past', 'Archived'];

  List<ChatTutor> get _activeList => switch (_tabIndex) {
        0 => _inbox,
        1 => _past,
        _ => _archived,
      };

  List<ChatTutor> get _currentList {
    if (_search.isEmpty) return _activeList;
    final q = _search.toLowerCase();
    return _activeList
        .where((t) =>
            t.name.toLowerCase().contains(q) ||
            t.subject.toLowerCase().contains(q) ||
            t.lastMessage.toLowerCase().contains(q))
        .toList();
  }

  int get _totalUnread =>
      _inbox.fold(0, (s, t) => s + t.unread) +
      _past.fold(0, (s, t) => s + t.unread);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _archiveTutor(ChatTutor tutor) {
    final src = _inbox.any((t) => t.id == tutor.id)
        ? _inbox
        : _past.any((t) => t.id == tutor.id)
            ? _past
            : null;
    if (src == null) return;
    setState(() { src.remove(tutor); _archived.insert(0, tutor); });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${tutor.name} archived'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () => setState(() { _archived.remove(tutor); src.insert(0, tutor); }),
      ),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
    ));
  }

  void _unarchiveTutor(ChatTutor tutor) {
    setState(() { _archived.remove(tutor); _inbox.insert(0, tutor); });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${tutor.name} moved to Inbox'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () => setState(() { _inbox.remove(tutor); _archived.insert(0, tutor); }),
      ),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
    ));
  }

  List<ChatMessage> _seedIfEmpty(String tutorId, String subject) {
    final list = _msgsFor(tutorId);
    if (list.isEmpty) {
      list.addAll([
        ChatMessage(
          text: 'Hello! I saw your profile and I think I can really help you with $subject.',
          isMe: false,
          time: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        ),
        ChatMessage(
          text: 'Hi! That sounds great. I have been struggling with a few topics.',
          isMe: true,
          time: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 55)),
        ),
        ChatMessage(
          text: 'No worries at all! Which topics are giving you trouble?',
          isMe: false,
          time: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 50)),
        ),
        ChatMessage(
          text: 'Mainly integration by parts and differential equations.',
          isMe: true,
          time: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 40)),
        ),
        ChatMessage(
          text: 'Sure! I can help you with integration by parts. Let us schedule a session.',
          isMe: false,
          time: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ]);
    }
    return list;
  }

  void _onQuickSend(ChatTutor tutor, String text) {
    _seedIfEmpty(tutor.id, tutor.subject).add(ChatMessage(text: text, isMe: true));
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.hour < 12 ? 'AM' : 'PM';
    final timeStr = '$h:$m $period';
    final updated = ChatTutor(
      id: tutor.id, name: tutor.name, subject: tutor.subject,
      avatarUrl: tutor.avatarUrl, lastMessage: text, time: timeStr,
      unread: tutor.unread, isOnline: tutor.isOnline, isVerified: tutor.isVerified,
      isPast: tutor.isPast, rating: tutor.rating, students: tutor.students,
      location: tutor.location, pricing: tutor.pricing,
    );
    setState(() {
      for (final list in [_inbox, _past, _archived]) {
        final idx = list.indexWhere((t) => t.id == tutor.id);
        if (idx != -1) {
          list[idx] = updated;
          if (list != _archived) {
            list.removeAt(idx);
            list.insert(0, updated);
          }
          break;
        }
      }
    });
  }

  void _openConversation(ChatTutor tutor) {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConversationScreen(
          tutor: tutor,
          isPast: tutor.isPast,
          messages: _msgsFor(tutor.id),
        ),
      ),
    );
  }

  void _showQuickSheet(ChatTutor tutor) {
    final isArchived = _tabIndex == 2;
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => QuickSheet(
        tutor: tutor,
        isPast: tutor.isPast,
        isArchived: isArchived,
        onArchive: () {
          Navigator.pop(context);
          if (isArchived) _unarchiveTutor(tutor); else _archiveTutor(tutor);
        },
        onSend: (text) => _onQuickSend(tutor, text),
        onOpen: () { Navigator.pop(context); _openConversation(tutor); },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final list = _currentList;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          _buildSearchBar(cs),
          _buildTabChips(cs, tt),
          const Divider(height: 1),
          Expanded(
            child: list.isEmpty
                ? _buildEmpty(cs, tt)
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) => ConversationTile(
                      tutor: list[i],
                      onTap: () => _openConversation(list[i]),
                      onLongPress: () => _showQuickSheet(list[i]),
                      isPast: list[i].isPast,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: SearchBar(
        controller: _searchCtrl,
        hintText: 'Search conversations',
        leading: const Icon(Icons.search_rounded),
        trailing: _search.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _search = '');
                  },
                )
              ]
            : null,
        onChanged: (v) => setState(() => _search = v),
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(cs.surfaceContainerHighest),
        padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16)),
      ),
    );
  }

  Widget _buildTabChips(ColorScheme cs, TextTheme tt) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: List.generate(_sections.length, (i) {
          final selected = _tabIndex == i;
          final showBadge = i == 0 && _totalUnread > 0;
          return Padding(
            padding: EdgeInsets.only(right: i < _sections.length - 1 ? 8 : 0),
            child: FilterChip(
              selected: selected,
              showCheckmark: false,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_sections[i]),
                  if (showBadge) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: selected ? cs.primary : cs.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$_totalUnread',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              onSelected: (_) {
                HapticFeedback.selectionClick();
                setState(() => _tabIndex = i);
              },
              selectedColor: cs.primaryContainer,
              backgroundColor: cs.surfaceContainerHighest,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              labelStyle: tt.labelLarge?.copyWith(
                color:
                    selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmpty(ColorScheme cs, TextTheme tt) {
    final (icon, label) = switch (_tabIndex) {
      0 => (Icons.inbox_outlined, 'No conversations yet'),
      1 => (Icons.history_rounded, 'No past tutors'),
      _ => (Icons.archive_outlined, 'Nothing archived'),
    };
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56,
              color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(label,
              style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}
