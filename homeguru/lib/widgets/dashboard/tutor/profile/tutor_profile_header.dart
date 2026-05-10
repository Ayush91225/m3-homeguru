import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../services/user_profile_store.dart';

class TutorProfileHeader extends StatelessWidget {
  const TutorProfileHeader({
    super.key,
    required this.onPickCover,
    required this.onPickAvatar,
    required this.topPad,
    this.viewMode = false,
  });

  final VoidCallback onPickCover;
  final VoidCallback onPickAvatar;
  final double topPad;
  final bool viewMode;

  static const _coverH  = 170.0;
  static const _avatarR = 46.0;
  static const _overlap = 32.0;

  static double get overlap => _overlap;

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final store = ProfileStore.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: _coverH + topPad,
          width: double.infinity,
          child: _Cover(cs: cs, image: store.cover),
        ),
        Positioned(
          top: topPad + 4,
          left: 4,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        if (!viewMode)
          Positioned(
            bottom: 10,
            right: 14,
            child: _EditCoverPill(onTap: onPickCover),
          ),
        Positioned(
          bottom: -_overlap,
          left: 20,
          child: _AvatarWidget(
            cs: cs,
            radius: _avatarR,
            image: store.avatar,
            onTap: onPickAvatar,
            viewMode: viewMode,
          ),
        ),
      ],
    );
  }
}

// ─── Cover ────────────────────────────────────────────────────────────────────

class _Cover extends StatelessWidget {
  const _Cover({required this.cs, required this.image});
  final ColorScheme cs;
  final File? image;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          image != null
              ? Image.file(image!, fit: BoxFit.cover)
              : Container(color: cs.surfaceContainerLow),
          if (image == null) ...[
            _Blob(top: -90,  right: -90, size: 280, color: const Color(0xFFBF5000), opacity: isDark ? 0.28 : 0.13),
            _Blob(top: -70,  left: -50,  size: 340, color: const Color(0xFFFF9F5C), opacity: isDark ? 0.14 : 0.08),
            _Blob(bottom: -70, left: -70, size: 220, color: const Color(0xFFE67E22), opacity: isDark ? 0.18 : 0.09),
          ],
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.18)],
                  stops: const [0.55, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({this.top, this.bottom, this.left, this.right,
      required this.size, required this.color, required this.opacity});
  final double? top, bottom, left, right;
  final double size, opacity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0.0)],
            stops: const [0.0, 0.85],
          ),
        ),
      ),
    );
  }
}

class _EditCoverPill extends StatelessWidget {
  const _EditCoverPill({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt_rounded, size: 12, color: Colors.white),
            SizedBox(width: 4),
            Text('Edit cover', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _AvatarWidget extends StatelessWidget {
  const _AvatarWidget({
    required this.cs,
    required this.radius,
    required this.image,
    required this.onTap,
    required this.viewMode,
  });
  final ColorScheme cs;
  final double radius;
  final File? image;
  final VoidCallback onTap;
  final bool viewMode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: viewMode ? null : onTap,
      child: Stack(
        children: [
          Container(
            width: radius * 2, height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: cs.surface, width: 3),
              color: cs.tertiaryContainer,
              boxShadow: [BoxShadow(color: cs.shadow.withValues(alpha: 0.18), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: ClipOval(
              child: image != null
                  ? Image.file(image!, fit: BoxFit.cover)
                  : Icon(Icons.person_rounded, size: radius, color: cs.onTertiaryContainer),
            ),
          ),
          if (!viewMode)
            Positioned(
              bottom: 2, right: 2,
              child: Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.tertiary,
                  border: Border.all(color: cs.surface, width: 1.5),
                ),
                child: Icon(Icons.camera_alt_rounded, size: 11, color: cs.onTertiary),
              ),
            ),
        ],
      ),
    );
  }
}
