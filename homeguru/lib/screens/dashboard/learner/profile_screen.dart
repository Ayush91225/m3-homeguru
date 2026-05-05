import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/user_profile_store.dart';
import '../../../widgets/dashboard/learner/profile/profile_header.dart';
import '../../../widgets/dashboard/learner/profile/profile_info.dart';
import '../../../widgets/dashboard/learner/profile/tabs/about_tab.dart';
import '../../../widgets/dashboard/learner/profile/tabs/achievements_tab.dart';
import '../../../widgets/dashboard/learner/profile/tabs/my_tutors_tab.dart';
import '../../../widgets/dashboard/learner/profile/tabs/settings_tab.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null && mounted) await ProfileStore.of(context).setCover(File(x.path));
  }

  Future<void> _pickAvatar() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null && mounted) await ProfileStore.of(context).setAvatar(File(x.path));
  }

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;
    final topPad = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: NestedScrollView(
          headerSliverBuilder: (_, _) => [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  ProfileHeader(
                    onPickCover: _pickCover,
                    onPickAvatar: _pickAvatar,
                    topPad: topPad,
                  ),
                  SizedBox(height: ProfileHeader.overlap + 8),
                  const ProfileInfo(),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tab,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelStyle: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                  unselectedLabelStyle: tt.labelMedium,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: cs.outlineVariant.withValues(alpha: 0.4),
                  tabs: const [
                    Tab(text: 'About'),
                    Tab(text: 'Achievements'),
                    Tab(text: 'My Tutors'),
                    Tab(text: 'Settings'),
                  ],
                ),
                cs,
              ),
            ),
          ],
          body: TabBarView(
            controller: _tab,
            children: const [
              AboutTab(),
              AchievementsTab(),
              MyTutorsTab(),
              SettingsTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate(this.tabBar, this.cs);
  final TabBar tabBar;
  final ColorScheme cs;

  @override double get minExtent => tabBar.preferredSize.height;
  @override double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(_, _, _) => ColoredBox(color: cs.surface, child: tabBar);

  @override
  bool shouldRebuild(_TabBarDelegate old) => old.tabBar != tabBar;
}
