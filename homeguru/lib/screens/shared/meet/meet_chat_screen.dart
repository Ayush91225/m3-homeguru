import 'package:flutter/material.dart';
import '../chat/chat_models.dart';


class MeetChatScreen extends StatefulWidget {
  final String meetingCode;
  final String userName;
  final ChatTutor? tutor;
  final List<ChatMessage>? existingMessages;

  const MeetChatScreen({
    super.key,
    required this.meetingCode,
    required this.userName,
    this.tutor,
    this.existingMessages,
  });

  @override
  State<MeetChatScreen> createState() => _MeetChatScreenState();
}

class _MeetChatScreenState extends State<MeetChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late final List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = widget.existingMessages ?? [];
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isMe: true,
        time: DateTime.now(),
        isInCallMessage: true,
        meetingCode: widget.meetingCode,
      ));
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'In-call messages',
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.tutor != null 
                  ? '${widget.tutor!.subject} • ${widget.meetingCode}'
                  : 'Meeting: ${widget.meetingCode}',
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 56,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No messages yet',
                          style: tt.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Send a message to everyone in the meeting',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _MessageBubble(
                        message: message,
                        userName: widget.userName,
                        tutorName: widget.tutor?.name ?? 'Tutor',
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          _buildMessageInput(cs, tt),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ColorScheme cs, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: cs.surface,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Send a message to everyone',
                  hintStyle: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final String userName;
  final String tutorName;

  const _MessageBubble({
    required this.message,
    required this.userName,
    required this.tutorName,
  });

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final senderName = message.isMe ? userName : tutorName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: cs.primaryContainer,
              child: Text(
                senderName[0].toUpperCase(),
                style: tt.labelMedium?.copyWith(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!message.isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 4),
                    child: Text(
                      senderName,
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: message.isMe
                        ? cs.primaryContainer
                        : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: tt.bodyMedium?.copyWith(
                          color: message.isMe
                              ? cs.onPrimaryContainer
                              : cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(message.time),
                        style: tt.labelSmall?.copyWith(
                          color: message.isMe
                              ? cs.onPrimaryContainer.withValues(alpha: 0.7)
                              : cs.onSurfaceVariant.withValues(alpha: 0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (message.isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: cs.primary,
              child: Text(
                senderName[0].toUpperCase(),
                style: tt.labelMedium?.copyWith(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
