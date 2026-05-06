import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'calendar_types.dart';
import '../../screens/shared/chat/chat_models.dart';
import '../../screens/shared/chat/conversation_screen.dart';

class RescheduleRequestSheet extends StatelessWidget {
  final CalendarEvent event;
  final DateTime newDate;
  final String newTimeSlot;

  const RescheduleRequestSheet({
    super.key,
    required this.event,
    required this.newDate,
    required this.newTimeSlot,
  });

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
              Icon(Icons.schedule_send_rounded, color: cs.primary),
              const SizedBox(width: 12),
              Text('Reschedule Request', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 24),
          if (event.teacherImage != null) ...[
            CircleAvatar(
              radius: 32,
              backgroundImage: CachedNetworkImageProvider(event.teacherImage!),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            event.teacher ?? 'Your tutor',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'has requested to reschedule the class',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Schedule',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 16, color: cs.onSurface),
                              const SizedBox(width: 8),
                              Text(
                                _formatDate(event.date),
                                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded, size: 16, color: cs.onSurface),
                              const SizedBox(width: 8),
                              Text(
                                '${event.startMinutes ~/ 60}:${(event.startMinutes % 60).toString().padLeft(2, '0')}',
                                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded, color: cs.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New Schedule',
                            style: tt.labelSmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 16, color: cs.primary),
                              const SizedBox(width: 8),
                              Text(
                                _formatDate(newDate),
                                style: tt.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: cs.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded, size: 16, color: cs.primary),
                              const SizedBox(width: 8),
                              Text(
                                newTimeSlot,
                                style: tt.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: cs.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 20, color: cs.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Please review the new schedule and respond',
                    style: tt.bodySmall?.copyWith(color: cs.onSurface),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reschedule request declined'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    side: BorderSide(color: cs.error),
                  ),
                  child: Text('Decline', style: TextStyle(color: cs.error)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reschedule request accepted'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              final chatTutor = ChatTutor(
                id: event.id,
                name: event.teacher ?? 'Tutor',
                subject: event.subject ?? '',
                avatarUrl: event.teacherImage ?? '',
                lastMessage: '',
                time: '',
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ConversationScreen(
                    tutor: chatTutor,
                    messages: [],
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            label: Text('Message ${event.teacher?.split(' ').first ?? 'Tutor'}'),
          ),
        ],
      ),
    );
  }
}
