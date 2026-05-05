import 'package:flutter/material.dart';
import '../../../screens/dashboard/learner/profile_screen.dart';
import '../../../services/user_profile_store.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

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
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: Builder(builder: (context) {
              final avatar = ProfileStore.of(context).avatar;
              return CircleAvatar(
                radius: 16,
                backgroundColor: cs.primaryContainer,
                backgroundImage:
                    avatar != null ? FileImage(avatar) : null,
                child: avatar == null
                    ? Icon(Icons.person_rounded,
                        size: 18, color: cs.onPrimaryContainer)
                    : null,
              );
            }),
          ),
        ),
      ],
    );
  }
}
