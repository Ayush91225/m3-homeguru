import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'calendar_types.dart';
import '../../screens/shared/chat/chat_models.dart';
import '../../screens/shared/chat/conversation_screen.dart';
import '../../screens/shared/meet/prejoin_screen.dart';
import '../../services/user_profile_store.dart';
import 'reschedule_sheet.dart';
import 'cancel_sheet.dart';

class ClassDetailSheet extends StatelessWidget {
  final CalendarEvent event;
  final bool isTutor;

  const ClassDetailSheet({super.key, required this.event, this.isTutor = false});

  Color _getToneColor(EventTone tone) {
    switch (tone) {
      case EventTone.blue:
        return Colors.blue.shade600;
      case EventTone.teal:
        return Colors.teal.shade600;
      case EventTone.violet:
        return Colors.deepPurple.shade600;
      case EventTone.amber:
        return Colors.amber.shade700;
      case EventTone.rose:
        return Colors.pink.shade600;
    }
  }

  String _formatTime(int minutes) {
    final hour = minutes ~/ 60;
    final min = minutes % 60;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${min.toString().padLeft(2, '0')} $period';
  }

  bool _canJoinNow() {
    final now = DateTime.now();
    final classDateTime = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
      event.startMinutes ~/ 60,
      event.startMinutes % 60,
    );
    final difference = classDateTime.difference(now);
    return difference.inMinutes <= 10 && difference.inMinutes >= -60;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = isTutor ? cs.tertiary : _getToneColor(event.tone);
    final canJoin = _canJoinNow();

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (event.teacherImage != null) ...[
                CircleAvatar(
                  radius: 28,
                  backgroundImage: CachedNetworkImageProvider(event.teacherImage!),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (event.teacher != null)
                      Text(
                        event.teacher!,
                        style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (event.subject != null)
                  Chip(
                    label: Text(event.subject!, style: TextStyle(fontSize: 12)),
                    backgroundColor: color.withValues(alpha: 0.12),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                if (event.sessionNumber != null && event.totalSessions != null)
                  Chip(
                    label: Text('${event.sessionNumber}/${event.totalSessions}', style: TextStyle(fontSize: 12)),
                    backgroundColor: cs.surfaceContainerHighest,
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                if (event.price != null && event.price! > 0)
                  Chip(
                    label: Text('₹${event.price}', style: TextStyle(fontSize: 12)),
                    backgroundColor: cs.surfaceContainerHighest,
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.access_time_rounded, color: cs.onSurfaceVariant),
            title: Text('${_formatTime(event.startMinutes)} - ${_formatTime(event.endMinutes)}'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
          if (event.meetingId != null)
            ListTile(
              leading: Icon(Icons.videocam_rounded, color: cs.onSurfaceVariant),
              title: Text(event.meetingId!),
              trailing: IconButton(
                icon: Icon(Icons.copy_rounded, size: 18, color: isTutor ? cs.tertiary : cs.primary),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: event.meetingId!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Copied'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: canJoin ? () {
              final profile = ProfileStore.of(context);
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PrejoinScreen(
                    meetingCode: event.meetingId ?? 'HG-${event.id.hashCode % 10000}',
                    userName: profile.name,
                    userRole: 'Learner',
                    event: event,
                    tutor: ChatTutor(
                      id: event.id,
                      name: event.teacher ?? event.title,
                      subject: event.subject ?? event.title,
                      avatarUrl: event.teacherImage ?? '',
                      lastMessage: '',
                      time: '',
                      isVerified: true,
                      isOnline: true,
                    ),
                    chatMessages: [],
                  ),
                ),
              );
            } : null,
            style: FilledButton.styleFrom(
              backgroundColor: color,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('Join Session'),
          ),
          const SizedBox(height: 12),
          if (event.isTrial != true) ...[
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                final tutor = ChatTutor(
                  id: event.id,
                  name: event.teacher ?? event.title,
                  subject: event.subject ?? event.title,
                  avatarUrl: event.teacherImage ?? '',
                  lastMessage: '',
                  time: '',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConversationScreen(
                      tutor: tutor,
                      messages: [],
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                side: BorderSide(color: isTutor ? cs.tertiary : cs.primary),
              ),
              icon: Icon(Icons.chat_bubble_outline_rounded, size: 18, color: isTutor ? cs.tertiary : cs.primary),
              label: Text(
                isTutor ? 'Message ${event.title.split(' ').first}' : 'Message ${(event.teacher ?? '').split(' ').skip(1).join(' ')}',
                style: TextStyle(color: isTutor ? cs.tertiary : cs.primary),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => RescheduleSheet(event: event, isTutor: isTutor),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    side: BorderSide(color: isTutor ? cs.tertiary : cs.outline),
                  ),
                  child: Text('Reschedule', style: TextStyle(color: isTutor ? cs.tertiary : cs.onSurface)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => CancelSheet(event: event, isTutor: isTutor),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    side: BorderSide(color: cs.error),
                  ),
                  child: Text('Cancel', style: TextStyle(color: cs.error)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
