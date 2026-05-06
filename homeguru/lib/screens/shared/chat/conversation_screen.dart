import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'chat_models.dart';
import 'conversation_widgets.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    required this.tutor,
    this.isPast = false,
    required this.messages,
  });
  final ChatTutor tutor;
  final bool isPast;
  final List<ChatMessage> messages;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _scroll = ScrollController();
  final _picker = ImagePicker();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    if (widget.messages.isEmpty) {
      widget.messages.addAll([
        ChatMessage(
          text: 'Hello! I saw your profile and I think I can really help you with ${widget.tutor.subject}.',
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = false}) {
    if (!_scroll.hasClients) return;
    if (animated) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
    }
  }

  void _onSend(String text) {
    if (_sending) return;
    HapticFeedback.lightImpact();
    setState(() {
      widget.messages.add(ChatMessage(text: text, isMe: true));
      _sending = true;
    });
    Future.delayed(const Duration(milliseconds: 100),
        () => _scrollToBottom(animated: true));
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        widget.messages.add(ChatMessage(
          text: 'Got it! I will get back to you shortly.',
          isMe: false,
        ));
        _sending = false;
      });
      Future.delayed(const Duration(milliseconds: 100),
          () => _scrollToBottom(animated: true));
    });
  }

  Future<void> _pickImage() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      HapticFeedback.lightImpact();
      setState(() {
        widget.messages.add(ChatMessage(text: '', isMe: true, imageUrl: file.path));
      });
      Future.delayed(const Duration(milliseconds: 100),
          () => _scrollToBottom(animated: true));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not pick image: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: _buildAppBar(cs),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          if (widget.isPast)
            BlockedBar(tutor: widget.tutor)
          else
            ConversationInputBar(
              tutorFirstName: widget.tutor.name.split(' ').first,
              onSend: _onSend,
              onPickImage: _pickImage,
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme cs) {
    final tt = Theme.of(context).textTheme;

    return AppBar(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showTutorInfo(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: cs.surfaceContainerHighest,
                    backgroundImage: NetworkImage(widget.tutor.avatarUrl),
                  ),
                  if (widget.tutor.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF34A853),
                          shape: BoxShape.circle,
                          border: Border.all(color: cs.surface, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(widget.tutor.name,
                          style: tt.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      if (widget.tutor.isVerified) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.verified_rounded,
                            size: 14, color: cs.primary),
                      ],
                    ],
                  ),
                  Text(
                    widget.tutor.isOnline ? 'Online' : widget.tutor.subject,
                    style: tt.labelSmall?.copyWith(
                      color: widget.tutor.isOnline
                          ? const Color(0xFF34A853)
                          : cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline_rounded),
          tooltip: 'Tutor info',
          onPressed: _showTutorInfo,
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
    );
  }

  Widget _buildMessageList() {
    final msgs = widget.messages;
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: msgs.length,
      itemBuilder: (_, i) {
        final msg = msgs[i];
        final showDate =
            i == 0 || !_sameDay(msgs[i - 1].time, msg.time);
        return Column(
          children: [
            if (showDate) DateDivider(time: msg.time),
            MessageBubble(message: msg, tutor: widget.tutor),
          ],
        );
      },
    );
  }

  void _showTutorInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) =>
          TutorInfoSheet(tutor: widget.tutor, isPast: widget.isPast),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
