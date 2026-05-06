import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';
import '../../../screens/welcome/welcome_screen.dart';
import '../../../screens/shared/notifications_screen.dart';
import '../../../screens/shared/wallet/wallet_screen.dart';
import '../../../screens/dashboard/learner/store_screen.dart';
import '../../../screens/dashboard/learner/my_requests_screen.dart';
import '../../../screens/shared/meet/prejoin_screen.dart';
import '../../../services/user_profile_store.dart';
import '../../schedule/reschedule_request_sheet.dart';
import '../../schedule/payment_pending_sheet.dart';
import '../../schedule/calendar_types.dart';

class LearnerDrawer extends StatelessWidget {
  const LearnerDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_user');
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(color: cs.surfaceContainerLow),
            padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
            child: Image.asset(
              'assets/logo.png',
              height: 28,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _DrawerItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Home',
                  selected: selectedIndex == 0,
                  onTap: () {
                    onDestinationSelected(0);
                    Navigator.pop(context);
                  },
                ),
                _DrawerItem(
                  icon: Icons.search_outlined,
                  selectedIcon: Icons.search_rounded,
                  label: 'Search',
                  selected: selectedIndex == 1,
                  onTap: () {
                    onDestinationSelected(1);
                    Navigator.pop(context);
                  },
                ),
                _DrawerItem(
                  icon: Icons.calendar_today_outlined,
                  selectedIcon: Icons.calendar_today_rounded,
                  label: 'Schedule',
                  selected: selectedIndex == 2,
                  onTap: () {
                    onDestinationSelected(2);
                    Navigator.pop(context);
                  },
                ),
                _DrawerItem(
                  icon: Icons.send_outlined,
                  selectedIcon: Icons.send_rounded,
                  label: 'My Requests',
                  selected: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRequestsScreen()));
                  },
                ),
                _DrawerItem(
                  icon: Icons.auto_awesome_outlined,
                  selectedIcon: Icons.auto_awesome_rounded,
                  label: 'Guru AI',
                  selected: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/guru-ai');
                  },
                ),
                _DrawerItem(
                  icon: Icons.feed_outlined,
                  selectedIcon: Icons.feed_rounded,
                  label: 'Feed',
                  selected: selectedIndex == 3,
                  onTap: () {
                    onDestinationSelected(3);
                    Navigator.pop(context);
                  },
                ),
                _DrawerItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  selectedIcon: Icons.chat_bubble_rounded,
                  label: 'Chat',
                  selected: selectedIndex == 4,
                  onTap: () {
                    onDestinationSelected(4);
                    Navigator.pop(context);
                  },
                ),
                const Divider(height: 16),
                _DrawerItem(
                  icon: Icons.storefront_outlined,
                  selectedIcon: Icons.storefront_rounded,
                  label: 'HG Store',
                  selected: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreScreen()));
                  },
                ),
                _DrawerItem(
                  icon: Icons.account_balance_wallet_outlined,
                  selectedIcon: Icons.account_balance_wallet_rounded,
                  label: 'Wallet',
                  selected: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
                  },
                ),
                _DrawerItem(
                  icon: Icons.notifications_none_rounded,
                  selectedIcon: Icons.notifications_rounded,
                  label: 'Notifications',
                  selected: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                  },
                ),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings_rounded,
                  label: 'Settings',
                  selected: false,
                  onTap: () => Navigator.pop(context),
                ),
                _DrawerItem(
                  icon: Icons.help_outline_rounded,
                  selectedIcon: Icons.help_rounded,
                  label: 'Help & feedback',
                  selected: false,
                  onTap: () => Navigator.pop(context),
                ),
                const Divider(height: 16),
                const _TestCard(),
              ],
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: themeModeNotifier,
                  builder: (context, mode, _) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () async {
                          themeModeNotifier.value = ThemeMode.light;
                          await saveTheme(ThemeMode.light);
                        },
                        icon: const Icon(Icons.light_mode_outlined),
                        isSelected: mode == ThemeMode.light,
                        style: IconButton.styleFrom(
                          backgroundColor: mode == ThemeMode.light ? cs.secondaryContainer : null,
                          foregroundColor: mode == ThemeMode.light ? cs.onSecondaryContainer : null,
                        ),
                        tooltip: 'Light',
                      ),
                      IconButton(
                        onPressed: () async {
                          themeModeNotifier.value = ThemeMode.system;
                          await saveTheme(ThemeMode.system);
                        },
                        icon: const Icon(Icons.brightness_auto_outlined),
                        isSelected: mode == ThemeMode.system,
                        style: IconButton.styleFrom(
                          backgroundColor: mode == ThemeMode.system ? cs.secondaryContainer : null,
                          foregroundColor: mode == ThemeMode.system ? cs.onSecondaryContainer : null,
                        ),
                        tooltip: 'Auto',
                      ),
                      IconButton(
                        onPressed: () async {
                          themeModeNotifier.value = ThemeMode.dark;
                          await saveTheme(ThemeMode.dark);
                        },
                        icon: const Icon(Icons.dark_mode_outlined),
                        isSelected: mode == ThemeMode.dark,
                        style: IconButton.styleFrom(
                          backgroundColor: mode == ThemeMode.dark ? cs.secondaryContainer : null,
                          foregroundColor: mode == ThemeMode.dark ? cs.onSecondaryContainer : null,
                        ),
                        tooltip: 'Dark',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () => _logout(context),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? cs.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  color: selected ? cs.onSecondaryContainer : cs.onSurfaceVariant,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: tt.labelLarge?.copyWith(
                      color: selected ? cs.onSecondaryContainer : cs.onSurfaceVariant,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _TestCard extends StatelessWidget {
  const _TestCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.error.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report_rounded, size: 16, color: cs.error),
              const SizedBox(width: 8),
              Text(
                'TEST BUTTONS',
                style: tt.labelMedium?.copyWith(
                  color: cs.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => RescheduleRequestSheet(
                  event: CalendarEvent(
                    id: 'temp',
                    title: 'Mathematics Class',
                    date: DateTime.now(),
                    startMinutes: 540,
                    endMinutes: 600,
                    allDay: false,
                    calendarId: 'temp',
                    tone: EventTone.blue,
                    type: 'class',
                    teacher: 'Priya Sharma',
                    teacherImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop',
                  ),
                  newDate: DateTime.now().add(const Duration(days: 2)),
                  newTimeSlot: '3:00 PM',
                ),
              );
            },
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(32),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              backgroundColor: cs.surface,
            ),
            child: Text(
              'Reschedule Request Sheet',
              style: TextStyle(fontSize: 11, color: cs.error),
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => PaymentPendingSheet(
                  tutorName: 'Priya Sharma',
                  tutorImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop',
                  subject: 'Mathematics',
                  level: 'JEE Advanced',
                  sessionsBooked: 100,
                  preferredSlot: 'Mon, Wed, Fri - 5:00 PM',
                  perHourPrice: 499,
                  classesPerWeek: 3,
                  durationMonths: 8,
                  bookingAcceptedAt: DateTime.now().subtract(const Duration(hours: 2)),
                ),
              );
            },
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(32),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              backgroundColor: cs.surface,
            ),
            child: Text(
              'Payment Pending Sheet',
              style: TextStyle(fontSize: 11, color: cs.error),
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () {
              final profile = ProfileStore.of(context);
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PrejoinScreen(
                    meetingCode: 'HG-1234',
                    userName: profile.name,
                    userRole: 'Learner',
                    event: CalendarEvent(
                      id: 'temp',
                      title: 'Mathematics Class',
                      date: DateTime.now(),
                      startMinutes: 540,
                      endMinutes: 600,
                      allDay: false,
                      calendarId: 'temp',
                      tone: EventTone.blue,
                      type: 'class',
                      teacher: 'Priya Sharma',
                      teacherImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop',
                    ),
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(32),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              backgroundColor: cs.surface,
            ),
            child: Text(
              'Prejoin Screen',
              style: TextStyle(fontSize: 11, color: cs.error),
            ),
          ),
        ],
      ),
    );
  }
}
