import 'package:flutter/material.dart';
import '../../schedule/reschedule_sheet.dart';
import '../../schedule/cancel_sheet.dart';
import '../../schedule/calendar_types.dart';
import '../../../screens/shared/meet/prejoin_screen.dart';
import '../../../screens/shared/chat/chat_models.dart';
import '../../../services/user_profile_store.dart';

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
        'isPaid': true,
      },
      {
        'tutor': 'Priya Sharma',
        'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop',
        'subject': 'Mathematics',
        'specialization': 'JEE Advanced',
        'location': 'Delhi',
        'dateTime': now.add(const Duration(hours: 2)),
        'isActive': false,
        'isPaid': false,
      },
      {
        'tutor': 'Ananya Reddy',
        'image': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop',
        'subject': 'Chemistry',
        'specialization': 'CBSE Grade 11-12',
        'location': 'Bangalore',
        'dateTime': now.add(const Duration(hours: 4)),
        'isActive': false,
        'isPaid': true,
      },
      {
        'tutor': 'Meera Patel',
        'image': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop',
        'subject': 'Biology',
        'specialization': 'NEET',
        'location': 'Ahmedabad',
        'dateTime': now.add(const Duration(hours: 6)),
        'isActive': false,
        'isPaid': false,
      },
      {
        'tutor': 'Rajesh Kumar',
        'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
        'subject': 'Physics',
        'specialization': 'JEE Mains',
        'location': 'Mumbai',
        'dateTime': now.add(const Duration(hours: 8)),
        'isActive': false,
        'isPaid': true,
      },
      {
        'tutor': 'Sneha Iyer',
        'image': 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=400&h=400&fit=crop',
        'subject': 'Mathematics',
        'specialization': 'CBSE Grade 9-10',
        'location': 'Chennai',
        'dateTime': now.add(const Duration(hours: 10)),
        'isActive': false,
        'isPaid': false,
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
    if (diff.inMinutes < 1) return 'Starting now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h ${diff.inMinutes % 60}min';
    return '${diff.inDays}d ${diff.inHours % 24}h';
  }

  void _showRescheduleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => RescheduleSheet(
        event: CalendarEvent(
          id: 'temp',
          title: 'Class',
          date: DateTime.now(),
          startMinutes: 540,
          endMinutes: 600,
          allDay: false,
          calendarId: 'temp',
          tone: EventTone.blue,
          type: 'class',
        ),
      ),
    );
  }

  void _showCancelSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => CancelSheet(
        event: CalendarEvent(
          id: 'temp',
          title: 'Class',
          date: DateTime.now(),
          startMinutes: 540,
          endMinutes: 600,
          allDay: false,
          calendarId: 'temp',
          tone: EventTone.blue,
          type: 'class',
        ),
      ),
    );
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
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
                                _getTimeUntil(startTime) == 'Starting now' ? 'Starting now' : 'Starts in ${_getTimeUntil(startTime)}',
                                style: tt.labelSmall?.copyWith(
                                  color: cs.onTertiaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: session['isPaid'] == true ? cs.primary : cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            session['isPaid'] == true ? 'Paid' : 'Demo',
                            style: tt.labelSmall?.copyWith(
                              color: session['isPaid'] == true ? cs.onPrimary : cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
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
                      session: session,
                      onReschedule: _showRescheduleSheet,
                      onCancel: _showCancelSheet,
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

class _SplitButton extends StatefulWidget {
  final bool isActive;
  final ColorScheme cs;
  final Map<String, dynamic> session;
  final VoidCallback onReschedule;
  final VoidCallback onCancel;

  const _SplitButton({
    required this.isActive,
    required this.cs,
    required this.session,
    required this.onReschedule,
    required this.onCancel,
  });

  @override
  State<_SplitButton> createState() => _SplitButtonState();
}

class _SplitButtonState extends State<_SplitButton> {
  final MenuController _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _menuController,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(widget.cs.surfaceContainer),
        elevation: const WidgetStatePropertyAll(3),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      menuChildren: [
        MenuItemButton(
          leadingIcon: Icon(Icons.schedule_rounded, size: 20, color: widget.cs.onSurface),
          child: Text('Reschedule', style: TextStyle(color: widget.cs.onSurface)),
          onPressed: () {
            _menuController.close();
            widget.onReschedule();
          },
        ),
        MenuItemButton(
          leadingIcon: Icon(Icons.cancel_rounded, size: 20, color: widget.cs.error),
          child: Text('Cancel', style: TextStyle(color: widget.cs.error)),
          onPressed: () {
            _menuController.close();
            widget.onCancel();
          },
        ),
      ],
      builder: (context, controller, child) {
        return SizedBox(
          height: 36,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                onPressed: widget.isActive ? () {
                  final profile = ProfileStore.of(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PrejoinScreen(
                        meetingCode: 'HG-${DateTime.now().millisecondsSinceEpoch % 10000}',
                        userName: profile.name,
                        userRole: 'Learner',
                        event: CalendarEvent(
                          id: 'temp',
                          title: '${widget.session['subject']} – ${widget.session['specialization']}',
                          date: widget.session['dateTime'],
                          startMinutes: (widget.session['dateTime'] as DateTime).hour * 60 + (widget.session['dateTime'] as DateTime).minute,
                          endMinutes: (widget.session['dateTime'] as DateTime).hour * 60 + (widget.session['dateTime'] as DateTime).minute + 60,
                          allDay: false,
                          calendarId: 'temp',
                          tone: EventTone.blue,
                          type: 'class',
                          teacher: widget.session['tutor'],
                          teacherImage: widget.session['image'],
                          subject: widget.session['subject'],
                          sessionNumber: 1,
                          totalSessions: 10,
                        ),
                        tutor: ChatTutor(
                          id: widget.session['tutor'],
                          name: widget.session['tutor'],
                          subject: widget.session['subject'],
                          avatarUrl: widget.session['image'],
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
                  backgroundColor: widget.cs.primaryContainer,
                  foregroundColor: widget.cs.onPrimaryContainer,
                  disabledBackgroundColor: widget.cs.surfaceContainerHighest,
                  disabledForegroundColor: widget.cs.onSurfaceVariant,
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
                    color: widget.isActive ? widget.cs.onPrimaryContainer : widget.cs.onSurfaceVariant,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: widget.cs.onPrimaryContainer.withValues(alpha: 0.2),
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
                    color: widget.cs.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(999),
                      bottomRight: Radius.circular(999),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 18,
                      color: widget.cs.onPrimaryContainer,
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
