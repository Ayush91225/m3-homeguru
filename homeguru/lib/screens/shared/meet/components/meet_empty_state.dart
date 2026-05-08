import 'package:flutter/material.dart';

class MeetEmptyState extends StatelessWidget {
  final String meetingCode;
  final VoidCallback onCopyLink;
  final VoidCallback onShareInvite;

  const MeetEmptyState({
    super.key,
    required this.meetingCode,
    required this.onCopyLink,
    required this.onShareInvite,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "You're the only one here",
            style: tt.headlineSmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Share this meeting link with others that you want in the meeting',
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Meeting link
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onCopyLink,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'meet.homeguru.com/$meetingCode',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.content_copy_rounded,
                      color: cs.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Share button
          FilledButton.icon(
            onPressed: onShareInvite,
            style: FilledButton.styleFrom(
              backgroundColor: cs.secondaryContainer,
              foregroundColor: cs.onSecondaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            icon: const Icon(Icons.share_rounded, size: 20),
            label: Text(
              'Share invite',
              style: tt.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
