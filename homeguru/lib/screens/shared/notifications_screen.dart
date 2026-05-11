import 'package:flutter/material.dart';

enum _NType { session, message, payment, system }

class _Notif {
  final _NType type;
  final String title;
  final String body;
  final String time;
  bool read;
  _Notif({required this.type, required this.title, required this.body, required this.time, this.read = false});
}

final _mock = [
  _Notif(type: _NType.session,  title: 'Session starting soon',        body: 'Your session with Priya Sharma starts in 15 minutes.',        time: '2 min ago'),
  _Notif(type: _NType.message,  title: 'New message',                  body: 'Vikram Singh: "I have shared the notes for today\'s class."',  time: '18 min ago'),
  _Notif(type: _NType.payment,  title: 'Payment successful',           body: '₹499 paid for Physics — JEE Mains session.',                  time: '1 hr ago'),
  _Notif(type: _NType.session,  title: 'Session completed',            body: 'Your session with Ananya Reddy has ended. Leave a review!',   time: '3 hr ago',   read: true),
  _Notif(type: _NType.message,  title: 'New message',                  body: 'Meera Patel: "Can we reschedule tomorrow\'s session?"',        time: '5 hr ago',   read: true),
  _Notif(type: _NType.system,   title: 'Profile incomplete',           body: 'Add your learning goals to get better tutor suggestions.',    time: 'Yesterday',  read: true),
  _Notif(type: _NType.payment,  title: 'Refund processed',             body: '₹299 refunded for cancelled Chemistry session.',              time: 'Yesterday',  read: true),
  _Notif(type: _NType.session,  title: 'Upcoming session reminder',    body: 'Session with Rajesh Kumar tomorrow at 10:00 AM.',             time: '2 days ago', read: true),
  _Notif(type: _NType.system,   title: 'New feature: Streak Calendar', body: 'Track your daily learning streak in the Home tab.',           time: '3 days ago', read: true),
  _Notif(type: _NType.message,  title: 'New message',                  body: 'Arjun Mehta: "Here is the homework for next week."',          time: '4 days ago', read: true),
];

final _mockTutor = [
  _Notif(type: _NType.session,  title: 'New session request',          body: 'Rahul Kumar requested a session for Physics - Class 12.',     time: '5 min ago'),
  _Notif(type: _NType.message,  title: 'New message',                  body: 'Priya Sharma: "Can we extend today\'s session by 15 mins?"',  time: '22 min ago'),
  _Notif(type: _NType.payment,  title: 'Payment received',             body: '₹850 credited for Chemistry session with Ananya Reddy.',      time: '1 hr ago'),
  _Notif(type: _NType.session,  title: 'Session starting soon',        body: 'Your session with Vikram Singh starts in 30 minutes.',        time: '2 hr ago',   read: true),
  _Notif(type: _NType.message,  title: 'New message',                  body: 'Meera Patel: "Thank you for the detailed explanation!"',      time: '4 hr ago',   read: true),
  _Notif(type: _NType.system,   title: 'Profile views increased',      body: 'Your profile was viewed 24 times this week.',                 time: 'Yesterday',  read: true),
  _Notif(type: _NType.payment,  title: 'Payout processed',             body: '₹12,450 transferred to your bank account.',                   time: 'Yesterday',  read: true),
  _Notif(type: _NType.session,  title: 'Session completed',            body: 'Session with Rajesh Kumar ended. Awaiting student review.',   time: '2 days ago', read: true),
  _Notif(type: _NType.system,   title: 'New review received',          body: 'Arjun Mehta rated you 5 stars: "Excellent teaching!"',        time: '3 days ago', read: true),
  _Notif(type: _NType.message,  title: 'New message',                  body: 'Sanya Gupta: "Could you share the practice problems?"',       time: '4 days ago', read: true),
];

IconData _iconFor(_NType t) => switch (t) {
  _NType.session => Icons.video_call_outlined,
  _NType.message => Icons.chat_bubble_outline_rounded,
  _NType.payment => Icons.receipt_long_outlined,
  _NType.system  => Icons.info_outline_rounded,
};

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, this.isTutor = false});
  final bool isTutor;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final List<_Notif> _notifs = List.of(widget.isTutor ? _mockTutor : _mock);

  int get _unread => _notifs.where((n) => !n.read).length;

  void _markAllRead() => setState(() { for (final n in _notifs) n.read = true; });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: Row(
          children: [
            Text('Notifications', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            if (_unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: widget.isTutor ? cs.tertiary : cs.primary, borderRadius: BorderRadius.circular(10)),
                child: Text('$_unread', style: tt.labelSmall?.copyWith(color: widget.isTutor ? cs.onTertiary : cs.onPrimary, fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
        actions: [
          if (_unread > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text('Mark all read', style: tt.labelMedium?.copyWith(color: widget.isTutor ? cs.tertiary : cs.primary)),
            ),
        ],
      ),
      body: _notifs.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 56, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  Text('No notifications', style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _notifs.length,
              itemBuilder: (_, i) => _NotifTile(
                notif: _notifs[i],
                isTutor: widget.isTutor,
                onTap: () => setState(() => _notifs[i].read = true),
                onDismiss: () => setState(() => _notifs.removeAt(i)),
              ),
            ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final _Notif notif;
  final bool isTutor;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotifTile({required this.notif, this.isTutor = false, required this.onTap, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final unread = !notif.read;

    return Dismissible(
      key: ValueKey(notif.title + notif.time),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: cs.errorContainer,
        child: Icon(Icons.delete_outline_rounded, color: cs.onErrorContainer),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: unread ? (isTutor ? cs.tertiaryContainer.withValues(alpha: 0.18) : cs.primaryContainer.withValues(alpha: 0.18)) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _iconFor(notif.type),
                size: 22,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: tt.titleSmall?.copyWith(
                              fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          notif.time,
                          style: tt.labelSmall?.copyWith(
                            color: unread ? (isTutor ? cs.tertiary : cs.primary) : cs.onSurfaceVariant,
                            fontWeight: unread ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(color: isTutor ? cs.tertiary : cs.primary, shape: BoxShape.circle),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notif.body,
                      style: tt.bodySmall?.copyWith(
                        color: unread ? cs.onSurface : cs.onSurfaceVariant,
                        fontWeight: unread ? FontWeight.w500 : FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
