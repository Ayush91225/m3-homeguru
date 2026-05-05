import 'dart:async';
import 'package:flutter/material.dart';

class SearchCard extends StatefulWidget {
  final VoidCallback onSearch;
  final TextEditingController controller;

  const SearchCard({
    super.key,
    required this.onSearch,
    required this.controller,
  });

  @override
  State<SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> {
  static const _placeholders = [
    'Need a maths tutor for JEE',
    'मुझे गणित ट्यूटर चाहिए',
    'எனக்கு கணிதம் ஆசிரியர் வேண்டும்',
    'నాకు గణితం ట్యూటర్ కావాలి',
    'મને ગણિત શિક્ષક જોઈએ છે',
    'ನನಗೆ ಗಣಿತ ಶಿಕ್ಷಕರು ಬೇಕು',
    'Search in any language...',
  ];

  // Use a ValueNotifier so only the TextField hint rebuilds, not the whole card
  final _hintNotifier = ValueNotifier<String>('');
  int _currentIndex = 0;
  int _charIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hintNotifier.dispose();
    super.dispose();
  }

  void _startTyping() {
    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted) return;
      if (_charIndex < _placeholders[_currentIndex].length) {
        _hintNotifier.value = _placeholders[_currentIndex].substring(0, ++_charIndex);
      } else {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) _startDeleting();
        });
      }
    });
  }

  void _startDeleting() {
    _timer = Timer.periodic(const Duration(milliseconds: 75), (timer) {
      if (!mounted) return;
      if (_charIndex > 0) {
        _hintNotifier.value = _placeholders[_currentIndex].substring(0, --_charIndex);
      } else {
        timer.cancel();
        _currentIndex = (_currentIndex + 1) % _placeholders.length;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _startTyping();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: Stack(
                  children: [
                    _GradientBlob(top: -120, right: -120, size: 320, color: const Color(0xFF4A90E2), opacity: isDark ? 0.5 : 0.25),
                    _GradientBlob(bottom: -100, left: -100, size: 280, color: const Color(0xFFFF9F5C), opacity: isDark ? 0.45 : 0.22),
                    _GradientBlob(top: -80, left: -60, size: 560, color: const Color(0xFFA8C5FF), opacity: isDark ? 0.22 : 0.12),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.search_rounded, size: 20, color: cs.primary),
                      const SizedBox(width: 8),
                      Text('Find Your Perfect Tutor', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Search in any language, naturally', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          // Only the hint text rebuilds on timer tick
                          child: ValueListenableBuilder<String>(
                            valueListenable: _hintNotifier,
                            builder: (_, hint, child) => TextField(
                              controller: widget.controller,
                              decoration: InputDecoration(
                                hintText: hint,
                                hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 13),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              ),
                              maxLines: null,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (v) => widget.onSearch(),
                              style: TextStyle(fontSize: 14, color: cs.onSurface),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: IconButton(
                            onPressed: widget.onSearch,
                            icon: Icon(Icons.search_rounded, color: cs.primary),
                            style: IconButton.styleFrom(backgroundColor: Colors.transparent, padding: const EdgeInsets.all(12)),
                            iconSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientBlob extends StatelessWidget {
  final double? top, bottom, left, right;
  final double size;
  final Color color;
  final double opacity;

  const _GradientBlob({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.85],
          ),
        ),
      ),
    );
  }
}
