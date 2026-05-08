import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../screens/dashboard/learner/profile_screen.dart';
import '../../../services/user_profile_store.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  Future<String?> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('logged_in_user');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
          child: FutureBuilder<String?>(
            future: _getUserRole(),
            builder: (context, snapshot) {
              final role = snapshot.data;
              final isLearner = role == 'learner';
              
              return GestureDetector(
                onTap: () {
                  if (isLearner) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  }
                  // TODO: Add tutor profile screen navigation
                },
                child: Builder(builder: (context) {
                  final avatar = ProfileStore.of(context).avatar;
                  final containerColor = isLearner ? cs.primaryContainer : cs.tertiaryContainer;
                  final iconColor = isLearner ? cs.onPrimaryContainer : cs.onTertiaryContainer;
                  
                  return CircleAvatar(
                    radius: 16,
                    backgroundColor: containerColor,
                    backgroundImage:
                        avatar != null ? FileImage(avatar) : null,
                    child: avatar == null
                        ? Icon(Icons.person_rounded,
                            size: 18, color: iconColor)
                        : null,
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }
}
