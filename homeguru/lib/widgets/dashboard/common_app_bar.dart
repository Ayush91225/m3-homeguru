import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../screens/dashboard/learner/profile_screen.dart';
import '../../../screens/dashboard/tutor/tutor_profile_screen.dart';
import '../../../services/user_profile_store.dart';
import '../../../services/tutor_profile_service.dart';

class DashboardAppBar extends StatefulWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  State<DashboardAppBar> createState() => _DashboardAppBarState();
}

class _DashboardAppBarState extends State<DashboardAppBar> {
  String? _role;
  String? _networkPhotoUrl;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('logged_in_user');
    final tutorId = prefs.getString('userId');

    if (mounted) setState(() => _role = role);

    if (tutorId != null) {
      final result = await TutorProfileService.getTutorProfile(tutorId);
      if (result['success'] == true && mounted) {
        final data = result['data'] as Map<String, dynamic>;
        final photo = data['profilePhoto'] as String?;
        if (photo != null && photo.isNotEmpty) {
          setState(() => _networkPhotoUrl = photo);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLearner = _role == 'learner';

    return AppBar(
      leading: Builder(
        builder: (context) => IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu_rounded),
        ),
      ),
      title: Image.asset(
        'assets/logo.png',
        height: 24,
        fit: BoxFit.contain,
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => isLearner
                      ? const ProfileScreen()
                      : const TutorProfileScreen(),
                ),
              );
            },
            child: Builder(builder: (context) {
              final avatar = ProfileStore.of(context).avatar;
              final containerColor = isLearner ? cs.primaryContainer : cs.tertiaryContainer;
              final iconColor = isLearner ? cs.onPrimaryContainer : cs.onTertiaryContainer;

              ImageProvider? imageProvider;
              if (avatar != null) {
                imageProvider = FileImage(avatar);
              } else if (_networkPhotoUrl != null) {
                imageProvider = NetworkImage(_networkPhotoUrl!);
              }

              return CircleAvatar(
                radius: 16,
                backgroundColor: containerColor,
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? Icon(Icons.person_rounded, size: 18, color: iconColor)
                    : null,
              );
            }),
          ),
        ),
      ],
    );
  }
}
