import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';
import '../../../screens/welcome/welcome_screen.dart';
import '../../../screens/shared/notifications_screen.dart';
import '../../../screens/dashboard/tutor/wallet/tutor_wallet_screen.dart';

class TutorDrawer extends StatelessWidget {
  const TutorDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all app data
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: 13,
              itemBuilder: (context, index) {
                if (index == 0) return _DrawerItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Home',
                  selected: selectedIndex == 0,
                  onTap: () {
                    onDestinationSelected(0);
                    Navigator.pop(context);
                  },
                );
                if (index == 1) return _DrawerItem(
                  icon: Icons.inbox_outlined,
                  selectedIcon: Icons.inbox_rounded,
                  label: 'Requests',
                  selected: selectedIndex == 1,
                  onTap: () {
                    onDestinationSelected(1);
                    Navigator.pop(context);
                  },
                );
                if (index == 2) return _DrawerItem(
                  icon: Icons.calendar_today_outlined,
                  selectedIcon: Icons.calendar_today_rounded,
                  label: 'Schedule',
                  selected: selectedIndex == 2,
                  onTap: () {
                    onDestinationSelected(2);
                    Navigator.pop(context);
                  },
                );
                if (index == 3) return _DrawerItem(
                  icon: Icons.auto_awesome_outlined,
                  selectedIcon: Icons.auto_awesome_rounded,
                  label: 'Guru AI',
                  selected: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/guru-ai');
                  },
                );
                if (index == 4) return _DrawerItem(
                  icon: Icons.feed_outlined,
                  selectedIcon: Icons.feed_rounded,
                  label: 'Feed',
                  selected: selectedIndex == 3,
                  onTap: () {
                    onDestinationSelected(3);
                    Navigator.pop(context);
                  },
                );
                if (index == 5) return _DrawerItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  selectedIcon: Icons.chat_bubble_rounded,
                  label: 'Chat',
                  selected: selectedIndex == 4,
                  onTap: () {
                    onDestinationSelected(4);
                    Navigator.pop(context);
                  },
                );
                if (index == 6) return const Divider(height: 16);
                if (index == 7) return _DrawerItem(
                  icon: Icons.account_balance_wallet_outlined,
                  selectedIcon: Icons.account_balance_wallet_rounded,
                  label: 'Wallet',
                  selected: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TutorWalletScreen()));
                  },
                );
                if (index == 8) return _DrawerItem(
                  icon: Icons.notifications_none_rounded,
                  selectedIcon: Icons.notifications_rounded,
                  label: 'Notifications',
                  selected: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                  },
                );
                if (index == 9) return _DrawerItem(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings_rounded,
                  label: 'Settings',
                  selected: false,
                  onTap: () => Navigator.pop(context),
                );
                if (index == 10) return _DrawerItem(
                  icon: Icons.help_outline_rounded,
                  selectedIcon: Icons.help_rounded,
                  label: 'Help & feedback',
                  selected: false,
                  onTap: () => Navigator.pop(context),
                );
                if (index == 11) return const Divider(height: 16);
                if (index == 12) return const SizedBox(height: 8);
                return const SizedBox.shrink();
              },
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
                          backgroundColor: mode == ThemeMode.light ? cs.tertiaryContainer : null,
                          foregroundColor: mode == ThemeMode.light ? cs.onTertiaryContainer : null,
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
                          backgroundColor: mode == ThemeMode.system ? cs.tertiaryContainer : null,
                          foregroundColor: mode == ThemeMode.system ? cs.onTertiaryContainer : null,
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
                          backgroundColor: mode == ThemeMode.dark ? cs.tertiaryContainer : null,
                          foregroundColor: mode == ThemeMode.dark ? cs.onTertiaryContainer : null,
                        ),
                        tooltip: 'Dark',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => _logout(context),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                    backgroundColor: cs.tertiaryContainer,
                    foregroundColor: cs.onTertiaryContainer,
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
        color: selected ? cs.tertiaryContainer : Colors.transparent,
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
                  color: selected ? cs.onTertiaryContainer : cs.onSurfaceVariant,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: tt.labelLarge?.copyWith(
                      color: selected ? cs.onTertiaryContainer : cs.onSurfaceVariant,
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
