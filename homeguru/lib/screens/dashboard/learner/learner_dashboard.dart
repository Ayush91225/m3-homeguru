import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../widgets/mascot/hoot_sprite.dart';
import '../../../widgets/dashboard/common_app_bar.dart';
import '../../../widgets/dashboard/learner/learner_drawer.dart';
import 'home_tab.dart';
import 'search_tab.dart';
import 'schedule_tab.dart';
import 'feed_tab.dart';
import 'chat_tab.dart';

class LearnerDashboard extends StatefulWidget {
  const LearnerDashboard({super.key});

  @override
  State<LearnerDashboard> createState() => LearnerDashboardState();
}

class LearnerDashboardState extends State<LearnerDashboard> {
  int _selectedIndex = 0;
  bool _fabExtended = true;

  static const _tabs = [
    HomeTab(),
    SearchTab(),
    ScheduleTab(),
    FeedTab(),
    ChatTab(),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _fabExtended = false);
      }
    });
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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const DashboardAppBar(),
      drawer: LearnerDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: onItemTapped,
      ),
      body: _tabs[_selectedIndex],
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        width: _fabExtended ? 140 : 56,
        height: 56,
        child: Material(
          color: cs.primaryContainer,
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
                      color: cs.onPrimaryContainer,
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Search',
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
