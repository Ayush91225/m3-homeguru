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
  List<_Notif> _notifs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _loading = true);
    // TODO: Fetch from API - for now show empty
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _notifs = []; // Will be populated from API
      _loading = false;
    });
  }

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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifs.isEmpty
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
