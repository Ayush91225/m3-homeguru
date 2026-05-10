import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/mascot/hoot_sprite.dart';
import '../../../widgets/dashboard/common_app_bar.dart';
import '../../../widgets/dashboard/tutor/tutor_drawer.dart';
import 'home_tab.dart';
import 'requests_tab.dart';
import 'schedule_tab.dart';
import 'feed_tab.dart';
import 'chat_tab.dart';

class TutorDashboard extends StatefulWidget {
  const TutorDashboard({super.key});

  @override
  State<TutorDashboard> createState() => TutorDashboardState();
}

class TutorDashboardState extends State<TutorDashboard> {
  int _selectedIndex = 0;
  bool _fabExtended = true;
  bool _isLoading = true;

  static const _tabs = [
    TutorHomeTab(),
    TutorRequestsTab(),
    TutorScheduleTab(),
    TutorFeedTab(),
    TutorChatTab(),
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthAndOnboarding();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _fabExtended = false);
      }
    });
  }

  Future<void> _checkAuthAndOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedInUser = prefs.getString('logged_in_user');
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

    if (!mounted) return;

    if (loggedInUser == null || loggedInUser.isEmpty) {
      // Not logged in - redirect to welcome page
      Navigator.of(context).pushReplacementNamed('/welcome');
      return;
    }

    if (!onboardingComplete) {
      // Onboarding not complete - redirect to welcome page
      Navigator.of(context).pushReplacementNamed('/welcome');
      return;
    }

    setState(() => _isLoading = false);
  }

  void onItemTapped(int index) {
    if (index == _selectedIndex) return;
    HapticFeedback.lightImpact();
    setState(() => _selectedIndex = index);
  }

  void _onFabTapped() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, '/guru-ai');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const DashboardAppBar(),
      drawer: TutorDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: onItemTapped,
      ),
      body: _tabs[_selectedIndex],
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        width: _fabExtended ? 140 : 56,
        height: 68,
        child: Material(
          color: cs.tertiaryContainer,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            bottomLeft: Radius.circular(28),
          ),
          elevation: 3,
          child: InkWell(
            onTap: _onFabTapped,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              bottomLeft: Radius.circular(28),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: HootSprite(),
                ),
                if (_fabExtended) ...[
                  const SizedBox(width: 8),
                  Text(
                    'Guru AI',
                    style: TextStyle(
                      color: cs.onTertiaryContainer,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: const _RightEdgeFabLocation(),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            indicatorColor: cs.tertiaryContainer,
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return IconThemeData(color: cs.onTertiaryContainer);
              }
              return IconThemeData(color: cs.onSurfaceVariant);
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return TextStyle(
                  color: cs.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                );
              }
              return TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              );
            }),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: onItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.inbox_outlined),
              selectedIcon: Icon(Icons.inbox_rounded),
              label: 'Requests',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today_rounded),
              label: 'Schedule',
            ),
            NavigationDestination(
              icon: Icon(Icons.feed_outlined),
              selectedIcon: Icon(Icons.feed_rounded),
              label: 'Feed',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              selectedIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Chat',
            ),
          ],
        ),
      ),
    );
  }
}

class _RightEdgeFabLocation extends FloatingActionButtonLocation {
  const _RightEdgeFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX = scaffoldGeometry.scaffoldSize.width - scaffoldGeometry.floatingActionButtonSize.width;
    final double fabY = scaffoldGeometry.contentBottom -
        scaffoldGeometry.floatingActionButtonSize.height -
        16.0;
    return Offset(fabX, fabY);
  }
}
