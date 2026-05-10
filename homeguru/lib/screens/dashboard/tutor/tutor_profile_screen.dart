import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/user_profile_store.dart';
import '../../../widgets/dashboard/tutor/profile/tutor_profile_header.dart';
import '../../../widgets/dashboard/tutor/profile/tutor_profile_info.dart';
import '../../../widgets/dashboard/tutor/profile/tabs/tutor_about_tab.dart';
import '../../../widgets/dashboard/tutor/profile/tabs/tutor_availability_tab.dart';
import '../../../widgets/dashboard/tutor/profile/tabs/tutor_reviews_tab.dart';
import '../../../widgets/dashboard/tutor/profile/tabs/tutor_my_learners_tab.dart';
import '../../../widgets/dashboard/tutor/profile/tabs/tutor_settings_tab.dart';

class TutorProfileScreen extends StatefulWidget {
  const TutorProfileScreen({super.key, this.viewMode = false});
  
  final bool viewMode;

  @override
  State<TutorProfileScreen> createState() => _TutorProfileScreenState();
}

class _TutorProfileScreenState extends State<TutorProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: widget.viewMode ? 3 : 5, vsync: this);
  }

  @override
  void didUpdateWidget(TutorProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewMode != widget.viewMode) {
      _tab.dispose();
      _tab = TabController(length: widget.viewMode ? 3 : 5, vsync: this);
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    if (widget.viewMode) return;
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null && mounted) await ProfileStore.of(context).setCover(File(x.path));
  }

  Future<void> _pickAvatar() async {
    if (widget.viewMode) return;
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null && mounted) await ProfileStore.of(context).setAvatar(File(x.path));
  }

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;
    final topPad = MediaQuery.of(context).padding.top;

    return Theme(
      data: Theme.of(context).copyWith(
        tabBarTheme: TabBarThemeData(
          indicatorColor: cs.tertiary,
          labelColor: cs.tertiary,
          unselectedLabelColor: cs.onSurfaceVariant,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return cs.tertiary;
            return null;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return cs.tertiaryContainer;
            return null;
          }),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: cs.tertiary,
            foregroundColor: cs.onTertiary,
          ),
        ),
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: cs.surface,
          body: NestedScrollView(
            headerSliverBuilder: (_, _) => [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    TutorProfileHeader(
                      onPickCover: _pickCover,
                      onPickAvatar: _pickAvatar,
                      topPad: topPad,
                      viewMode: widget.viewMode,
                    ),
                    SizedBox(height: TutorProfileHeader.overlap + 8),
                    TutorProfileInfo(viewMode: widget.viewMode),
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
                    tabs: widget.viewMode
                        ? const [
                            Tab(text: 'About'),
                            Tab(text: 'Availability'),
                            Tab(text: 'Reviews'),
                          ]
                        : const [
                            Tab(text: 'About'),
                            Tab(text: 'Availability'),
                            Tab(text: 'Reviews'),
                            Tab(text: 'My Learners'),
                            Tab(text: 'Settings'),
                          ],
                  ),
                  cs,
                ),
              ),
            ],
            body: TabBarView(
              controller: _tab,
              children: widget.viewMode
                  ? const [
                      TutorAboutTab(viewMode: true),
                      TutorAvailabilityTab(viewMode: true),
                      TutorReviewsTab(viewMode: true),
                    ]
                  : const [
                      TutorAboutTab(viewMode: false),
                      TutorAvailabilityTab(viewMode: false),
                      TutorReviewsTab(viewMode: false),
                      TutorMyLearnersTab(),
                      TutorSettingsTab(),
                    ],
            ),
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
