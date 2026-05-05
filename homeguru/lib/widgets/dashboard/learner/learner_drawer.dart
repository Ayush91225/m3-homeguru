import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';
import '../../../screens/welcome/welcome_screen.dart';
import '../../../screens/shared/notifications_screen.dart';
import '../../../screens/shared/wallet/wallet_screen.dart';

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
