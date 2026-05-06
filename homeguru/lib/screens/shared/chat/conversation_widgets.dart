import 'dart:io';
import 'package:flutter/material.dart';

import 'chat_models.dart';
import 'chat_widgets.dart';
import '../sessions_listing_screen.dart';
import '../../../widgets/shared/tutor_action_sheet.dart';

// ─── Full-screen image viewer ─────────────────────────────────────────────────

class _ImageViewer extends StatelessWidget {
  const _ImageViewer({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: Image.file(File(path), fit: BoxFit.contain),
        ),
      ),
    );
  }
}

// ─── Message bubble ───────────────────────────────────────────────────────────

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, required this.tutor});
  final ChatMessage message;
  final ChatTutor tutor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isMe = message.isMe;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(tutor.avatarUrl),
              backgroundColor: cs.surfaceContainerHighest,
            ),
            const SizedBox(width: 6),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.68,
            ),
            child: Container(
              padding: message.imageUrl != null
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? cs.primaryContainer : cs.surfaceContainerHigh,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (message.imageUrl != null)
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _ImageViewer(path: message.imageUrl!),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isMe ? 18 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 18),
                        ),
                        child: Image.file(
                          File(message.imageUrl!),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 200,
                            height: 200,
                            color: cs.surfaceContainerHighest,
                            child: Icon(Icons.broken_image_outlined,
                                color: cs.onSurfaceVariant),
                          ),
                        ),
                      ),
                    )
                  else
                    Text(
                      message.text,
                      style: tt.bodyMedium?.copyWith(
                        color: isMe ? cs.onPrimaryContainer : cs.onSurface,
                        height: 1.4,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: message.imageUrl != null
                        ? const EdgeInsets.fromLTRB(0, 0, 8, 6)
                        : EdgeInsets.zero,
                    child: Text(
                      _formatTime(message.time),
                      style: tt.labelSmall?.copyWith(
                        fontSize: 10,
                        color: isMe
                            ? cs.onPrimaryContainer.withValues(alpha: 0.6)
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }

  static String _formatTime(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}

// ─── Date divider ─────────────────────────────────────────────────────────────

class DateDivider extends StatelessWidget {
  const DateDivider({super.key, required this.time});
  final DateTime time;

  String _label() {
    final now = DateTime.now();
    final diff = DateTime(now.year, now.month, now.day)
        .difference(DateTime(time.year, time.month, time.day))
        .inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${time.day}/${time.month}/${time.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
              child: Divider(
                  color: cs.outlineVariant.withValues(alpha: 0.5))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(_label(),
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
          ),
          Expanded(
              child: Divider(
                  color: cs.outlineVariant.withValues(alpha: 0.5))),
        ],
      ),
    );
  }
}

// ─── Blocked bar (past tutors) ────────────────────────────────────────────────

class BlockedBar extends StatelessWidget {
  final ChatTutor? tutor;

  const BlockedBar({super.key, this.tutor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border(
            top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Messaging is disabled for past tutors.',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Book Again'),
              onPressed: tutor != null
                  ? () {
                      TutorActionSheet.show(
                        context,
                        tutorId: tutor!.id,
                        tutorName: tutor!.name,
                        tutorImage: tutor!.avatarUrl,
                        isVerified: tutor!.isVerified,
                        primarySubject: tutor!.subject,
                        tutorRating: tutor!.rating,
                        tutorStudents: tutor!.students,
                        tutorLocation: tutor!.location,
                        tutorPricing: tutor!.pricing,
                      );
                    }
                  : null,
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Input bar ────────────────────────────────────────────────────────────────

class ConversationInputBar extends StatefulWidget {
  const ConversationInputBar({
    super.key,
    required this.tutorFirstName,
    required this.onSend,
    required this.onPickImage,
  });

  final String tutorFirstName;
  final ValueChanged<String> onSend;
  final VoidCallback onPickImage;

  @override
  State<ConversationInputBar> createState() => _ConversationInputBarState();
}

class _ConversationInputBarState extends State<ConversationInputBar> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
            top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4))),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.image_outlined),
              tooltip: 'Send image',
              onPressed: widget.onPickImage,
              color: cs.onSurfaceVariant,
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _ctrl,
                  decoration: InputDecoration(
                    hintText: 'Message ${widget.tutorFirstName}…',
                    hintStyle: TextStyle(color: cs.onSurfaceVariant),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  style: TextStyle(fontSize: 15, color: cs.onSurface),
                  onSubmitted: (_) => _submit(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [cs.primary, cs.tertiary]
                      : [
                          Color.lerp(cs.primary, Colors.white, 0.2)!,
                          Color.lerp(cs.tertiary, Colors.white, 0.2)!,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.send_rounded, color: cs.onPrimary),
                onPressed: _submit,
                iconSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tutor info sheet ─────────────────────────────────────────────────────────

class TutorInfoSheet extends StatelessWidget {
  const TutorInfoSheet({super.key, required this.tutor, required this.isPast});
  final ChatTutor tutor;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          ChatAvatar(tutor: tutor, radius: 36),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(tutor.name,
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              if (tutor.isVerified) ...[
                const SizedBox(width: 6),
                Icon(Icons.verified_rounded, size: 18, color: cs.primary),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(tutor.subject,
              style: tt.bodyMedium?.copyWith(
                  color: cs.primary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.person_outline_rounded),
                  label: const Text('View Profile'),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  icon: Icon(isPast
                      ? Icons.refresh_rounded
                      : Icons.calendar_month_outlined),
                  label: Text(isPast ? 'Book Again' : 'Sessions'),
                  onPressed: () {
                    Navigator.pop(context);
                    if (isPast) {
                      TutorActionSheet.show(
                        context,
                        tutorId: tutor.id,
                        tutorName: tutor.name,
                        tutorImage: tutor.avatarUrl,
                        isVerified: tutor.isVerified,
                        primarySubject: tutor.subject,
                        tutorRating: tutor.rating,
                        tutorStudents: tutor.students,
                        tutorLocation: tutor.location,
                        tutorPricing: tutor.pricing,
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SessionsListingScreen(initialTutor: tutor.name),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
