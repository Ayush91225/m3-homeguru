import 'package:flutter/material.dart';

class UpcomingCard extends StatefulWidget {
  const UpcomingCard({super.key, this.onScheduleTap});

  final VoidCallback? onScheduleTap;

  @override
  State<UpcomingCard> createState() => _UpcomingCardState();
}

class _UpcomingCardState extends State<UpcomingCard> {
  int _currentIndex = 0;
  late final List<Map<String, dynamic>> _sessions;
  
  @override
  void initState() {
    super.initState();
    _sessions = [..._generateSessions(), {'isViewAll': true}];
  }
  
  List<Map<String, dynamic>> _generateSessions() {
    final now = DateTime.now();
    return [
      {
        'tutor': 'Vikram Singh',
        'image': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop',
        'subject': 'English',
        'specialization': 'IELTS',
        'location': 'Pune',
        'dateTime': now,
        'isActive': true,
      },
      {
        'tutor': 'Priya Sharma',
        'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop',
        'subject': 'Mathematics',
        'specialization': 'JEE Advanced',
        'location': 'Delhi',
        'dateTime': now.add(const Duration(hours: 2)),
        'isActive': false,
      },
      {
        'tutor': 'Ananya Reddy',
        'image': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop',
        'subject': 'Chemistry',
        'specialization': 'CBSE Grade 11-12',
        'location': 'Bangalore',
        'dateTime': now.add(const Duration(hours: 4)),
        'isActive': false,
      },
      {
        'tutor': 'Meera Patel',
        'image': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop',
        'subject': 'Biology',
        'specialization': 'NEET',
        'location': 'Ahmedabad',
        'dateTime': now.add(const Duration(hours: 6)),
        'isActive': false,
      },
    ];
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _formatDate(DateTime dateTime) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dateTime.day} ${months[dateTime.month - 1]}, ${dateTime.year}';
  }

  String _getTimeUntil(DateTime dateTime) {
    final now = DateTime.now();
    final diff = dateTime.difference(now);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h ${diff.inMinutes % 60}min';
    return '${diff.inDays}d ${diff.inHours % 24}h';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final session = _sessions[_currentIndex];
    
    if (session['isViewAll'] == true) {
      return _buildViewAllCard(cs, tt);
    }

    final startTime = session['dateTime'] as DateTime;
    final endTime = startTime.add(const Duration(hours: 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Upcoming Schedule',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0 && _currentIndex > 0) {
              setState(() => _currentIndex--);
            } else if (details.primaryVelocity! < 0 && _currentIndex < _sessions.length - 1) {
              setState(() => _currentIndex++);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: cs.surfaceContainer,
                      backgroundImage: NetworkImage(session['image']),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session['tutor'],
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.subject_rounded, size: 12, color: cs.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(
                                    session['subject'],
                                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                                  ),
                                ],
                              ),
                              Text(
                                session['location'],
                                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: cs.tertiaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule_rounded, size: 14, color: cs.onTertiaryContainer),
                          const SizedBox(width: 6),
                          Text(
                            'Starts in ${_getTimeUntil(startTime)}',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onTertiaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${session['subject']} – ${session['specialization']}',
                            style: tt.bodyLarge?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              Text(
                                '${_formatTime(startTime)} – ${_formatTime(endTime)}',
                                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w500),
                              ),
                              Text(_formatDate(startTime), style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    _SplitButton(
                      isActive: session['isActive'],
                      cs: cs,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16, right: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: _currentIndex > 0 ? () => setState(() => _currentIndex--) : null,
                style: IconButton.styleFrom(
                  backgroundColor: cs.surface,
                  side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                  disabledBackgroundColor: cs.surface,
                ),
                icon: Icon(Icons.chevron_left_rounded, color: cs.onSurfaceVariant),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${_currentIndex + 1} of ${_sessions.length}',
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: _currentIndex < _sessions.length - 1 ? () => setState(() => _currentIndex++) : null,
                style: IconButton.styleFrom(
                  backgroundColor: cs.surface,
                  side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                  disabledBackgroundColor: cs.surface,
                ),
                icon: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewAllCard(ColorScheme cs, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Upcoming Schedule',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: widget.onScheduleTap,
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0 && _currentIndex > 0) {
              setState(() => _currentIndex--);
            } else if (details.primaryVelocity! < 0 && _currentIndex < _sessions.length - 1) {
              setState(() => _currentIndex++);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
            ),
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 32,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'View Full Schedule',
                    style: tt.bodyLarge?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16, right: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: _currentIndex > 0 ? () => setState(() => _currentIndex--) : null,
                style: IconButton.styleFrom(
                  backgroundColor: cs.surface,
                  side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                  disabledBackgroundColor: cs.surface,
                ),
                icon: Icon(Icons.chevron_left_rounded, color: cs.onSurfaceVariant),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${_currentIndex + 1} of ${_sessions.length}',
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: _currentIndex < _sessions.length - 1 ? () => setState(() => _currentIndex++) : null,
                style: IconButton.styleFrom(
                  backgroundColor: cs.surface,
                  side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                  disabledBackgroundColor: cs.surface,
                ),
                icon: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SplitButton extends StatelessWidget {
  final bool isActive;
  final ColorScheme cs;

  const _SplitButton({required this.isActive, required this.cs});

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(cs.surfaceContainer),
        elevation: const WidgetStatePropertyAll(3),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      menuChildren: [
        MenuItemButton(
          leadingIcon: Icon(Icons.schedule_rounded, size: 20, color: cs.onSurface),
          child: Text('Reschedule', style: TextStyle(color: cs.onSurface)),
          onPressed: () {},
        ),
        MenuItemButton(
          leadingIcon: Icon(Icons.cancel_rounded, size: 20, color: cs.error),
          child: Text('Cancel', style: TextStyle(color: cs.error)),
          onPressed: () {},
        ),
      ],
      builder: (context, controller, child) {
        return SizedBox(
          height: 36,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                onPressed: isActive ? () {} : null,
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primaryContainer,
                  foregroundColor: cs.onPrimaryContainer,
                  disabledBackgroundColor: cs.surfaceContainerHighest,
                  disabledForegroundColor: cs.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(999),
                      bottomLeft: Radius.circular(999),
                    ),
                  ),
                  minimumSize: const Size(0, 36),
                  maximumSize: const Size(double.infinity, 36),
                ),
                child: Text(
                  'Join now',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isActive ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: cs.onPrimaryContainer.withValues(alpha: 0.2),
              ),
              InkWell(
                onTap: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(999),
                  bottomRight: Radius.circular(999),
                ),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(999),
                      bottomRight: Radius.circular(999),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 18,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
