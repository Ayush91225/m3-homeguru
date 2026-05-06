import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../widgets/schedule/calendar_types.dart';
import '../../../services/user_profile_store.dart';

class MeetingDetailsSheet extends StatelessWidget {
  final String meetingCode;
  final CalendarEvent? event;

  const MeetingDetailsSheet({
    super.key,
    required this.meetingCode,
    this.event,
  });

  String get meetingUrl => 'https://meet.homeguruworld.com/meeting/$meetingCode';

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final profile = ProfileStore.of(context);

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Meeting code & URL in compact card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
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
                                meetingCode,
                                style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                meetingUrl,
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _copyToClipboard(context, meetingCode, 'Code'),
                          icon: Icon(Icons.copy_rounded, size: 18),
                          style: IconButton.styleFrom(
                            backgroundColor: cs.surfaceContainerHighest,
                            minimumSize: const Size(36, 36),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Participants in grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Tutor
                  Expanded(
                    child: Container(
                      height: 88,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (event?.teacherImage != null)
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: cs.surfaceContainerHighest,
                                  backgroundImage: CachedNetworkImageProvider(event!.teacherImage!),
                                )
                              else
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: cs.tertiaryContainer,
                                  child: Icon(Icons.person, size: 18, color: cs.onTertiaryContainer),
                                ),
                              const SizedBox(width: 8),
                              Icon(Icons.school_rounded, size: 16, color: cs.onSurfaceVariant),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            event?.teacher ?? 'Tutor',
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Learner
                  Expanded(
                    child: Container(
                      height: 88,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (profile.avatar != null)
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage: FileImage(profile.avatar!),
                                )
                              else
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: cs.primaryContainer,
                                  child: Text(
                                    profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'L',
                                    style: tt.labelLarge?.copyWith(
                                      color: cs.onPrimaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Icon(Icons.person_rounded, size: 16, color: cs.onSurfaceVariant),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            profile.name,
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (event != null) ...[
              const SizedBox(height: 10),

              // Class details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (event!.title.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.class_outlined, size: 18, color: cs.onSurfaceVariant),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                event!.title,
                                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (event!.subject != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.subject_rounded, size: 18, color: cs.onSurfaceVariant),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                event!.subject!,
                                style: tt.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (event!.sessionNumber != null && event!.totalSessions != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.numbers_rounded, size: 18, color: cs.onSurfaceVariant),
                            const SizedBox(width: 10),
                            Text(
                              'Session ${event!.sessionNumber} of ${event!.totalSessions}',
                              style: tt.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 18, color: cs.onSurfaceVariant),
                          const SizedBox(width: 10),
                          Text(
                            '${_formatTime(event!.startMinutes)} - ${_formatTime(event!.endMinutes)}',
                            style: tt.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatTime(int minutes) {
    final hour = minutes ~/ 60;
    final min = minutes % 60;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${min.toString().padLeft(2, '0')} $period';
  }
}
