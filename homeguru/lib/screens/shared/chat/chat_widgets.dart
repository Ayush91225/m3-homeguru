import 'package:flutter/material.dart';
import 'chat_models.dart';
import '../../shared/sessions_listing_screen.dart';

// ─── Avatar with online indicator ─────────────────────────────────────────────

class ChatAvatar extends StatelessWidget {
  const ChatAvatar({super.key, required this.tutor, this.radius = 26});
  final ChatTutor tutor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dotSize = radius * 0.46;

    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: cs.surfaceContainerHighest,
          backgroundImage: NetworkImage(tutor.avatarUrl),
        ),
        if (tutor.isOnline)
          Positioned(
            bottom: 1,
            right: 1,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: const Color(0xFF34A853),
                shape: BoxShape.circle,
                border: Border.all(color: cs.surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Conversation tile ────────────────────────────────────────────────────────

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.tutor,
    required this.onTap,
    required this.onLongPress,
    this.isPast = false,
    this.isTutor = false,
  });

  final ChatTutor tutor;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isPast;
  final bool isTutor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hasUnread = tutor.unread > 0;
    final accentColor = isTutor ? cs.tertiary : cs.primary;
    final accentContainer = isTutor ? cs.tertiaryContainer : cs.primaryContainer;
    final onAccent = isTutor ? cs.onTertiary : cs.onPrimary;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        color: hasUnread
            ? accentContainer.withValues(alpha: 0.18)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChatAvatar(tutor: tutor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                tutor.name,
                                style: tt.titleSmall?.copyWith(
                                  fontWeight: hasUnread
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (tutor.isVerified) ...[
                              const SizedBox(width: 4),
                              Icon(Icons.verified_rounded,
                                  size: 14, color: accentColor),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tutor.time,
                        style: tt.labelSmall?.copyWith(
                          color: hasUnread ? accentColor : cs.onSurfaceVariant,
                          fontWeight:
                              hasUnread ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tutor.subject,
                    style: tt.labelSmall?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tutor.lastMessage,
                          style: tt.bodySmall?.copyWith(
                            color: hasUnread
                                ? cs.onSurface
                                : cs.onSurfaceVariant,
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${tutor.unread}',
                            style: tt.labelSmall?.copyWith(
                              color: onAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isPast) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.history_edu_rounded,
                            size: 14, color: cs.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          isTutor ? 'Past learner' : 'Past tutor',
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick action sheet ───────────────────────────────────────────────────────

class QuickSheet extends StatefulWidget {
  const QuickSheet({
    super.key,
    required this.tutor,
    required this.isPast,
    required this.isArchived,
    required this.onArchive,
    required this.onSend,
    required this.onOpen,
    this.isTutor = false,
  });

  final ChatTutor tutor;
  final bool isPast;
  final bool isArchived;
  final VoidCallback onArchive;
  final ValueChanged<String> onSend;
  final VoidCallback onOpen;
  final bool isTutor;

  @override
  State<QuickSheet> createState() => _QuickSheetState();
}

class _QuickSheetState extends State<QuickSheet> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _ctrl.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final t = widget.tutor;
    final accentColor = widget.isTutor ? cs.tertiary : cs.primary;
    final onAccent = widget.isTutor ? cs.onTertiary : cs.onPrimary;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 4),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                ChatAvatar(tutor: t),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(t.name,
                              style: tt.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          if (t.isVerified) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.verified_rounded,
                                size: 15, color: accentColor),
                          ],
                        ],
                      ),
                      Text(t.subject,
                          style: tt.labelSmall?.copyWith(color: accentColor)),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: widget.onOpen,
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Open'),
                  style: TextButton.styleFrom(
                      foregroundColor: accentColor,
                      visualDensity: VisualDensity.compact),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.calendar_month_outlined, color: cs.onSurfaceVariant),
            title: Text('Sessions', style: tt.bodyMedium),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SessionsListingScreen(
                    initialTutor: t.name,
                    isTutor: widget.isTutor,
                  ),
                ),
              );
            },
            dense: true,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              widget.isArchived
                  ? Icons.unarchive_outlined
                  : Icons.archive_outlined,
              color: cs.onSurfaceVariant,
            ),
            title: Text(
              widget.isArchived ? 'Unarchive conversation' : 'Archive conversation',
              style: tt.bodyMedium,
            ),
            onTap: widget.onArchive,
            dense: true,
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    focusNode: _focus,
                    enabled: !widget.isPast,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: widget.isPast
                          ? (widget.isTutor
                              ? 'Messaging disabled for past learners'
                              : 'Messaging disabled for past tutors')
                          : 'Quick message…',
                      hintStyle: tt.bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ValueListenableBuilder(
                  valueListenable: _ctrl,
                  builder: (_, v, _) => IconButton.filled(
                    onPressed:
                        (!widget.isPast && v.text.trim().isNotEmpty)
                            ? _send
                            : null,
                    icon: const Icon(Icons.send_rounded, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: onAccent,
                      disabledBackgroundColor:
                          cs.onSurface.withValues(alpha: 0.12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
