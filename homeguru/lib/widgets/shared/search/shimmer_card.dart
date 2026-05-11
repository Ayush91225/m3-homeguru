import 'package:flutter/material.dart';

class ShimmerCard extends StatefulWidget {
  final bool isLeft;
  final bool isTop;

  const ShimmerCard({
    super.key,
    required this.isLeft,
    required this.isTop,
  });

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? cs.surfaceContainerHigh : cs.surfaceContainer;
    final highlightColor = isDark ? cs.surfaceContainerHighest : cs.surfaceContainerHigh;

    BorderRadius? borderRadius;
    if (widget.isTop && widget.isLeft) {
      borderRadius = const BorderRadius.only(topLeft: Radius.circular(16));
    } else if (widget.isTop && !widget.isLeft) {
      borderRadius = const BorderRadius.only(topRight: Radius.circular(16));
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image shimmer - 60% height
            Expanded(
              flex: 3,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (_, _) => Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: [
                        (_animation.value - 0.5).clamp(0.0, 1.0),
                        _animation.value.clamp(0.0, 1.0),
                        (_animation.value + 0.5).clamp(0.0, 1.0),
                      ],
                      colors: [
                        baseColor,
                        highlightColor,
                        baseColor,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Info shimmer - 40% height
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name shimmer
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (_, _) => Container(
                            width: double.infinity,
                            height: 16,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                stops: [
                                  (_animation.value - 0.5).clamp(0.0, 1.0),
                                  _animation.value.clamp(0.0, 1.0),
                                  (_animation.value + 0.5).clamp(0.0, 1.0),
                                ],
                                colors: [
                                  baseColor,
                                  highlightColor,
                                  baseColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Subject shimmer
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (_, _) => Container(
                            width: 80,
                            height: 12,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                stops: [
                                  (_animation.value - 0.5).clamp(0.0, 1.0),
                                  _animation.value.clamp(0.0, 1.0),
                                  (_animation.value + 0.5).clamp(0.0, 1.0),
                                ],
                                colors: [
                                  baseColor,
                                  highlightColor,
                                  baseColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Experience shimmer
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (_, _) => Container(
                        width: 50,
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: [
                              (_animation.value - 0.5).clamp(0.0, 1.0),
                              _animation.value.clamp(0.0, 1.0),
                              (_animation.value + 0.5).clamp(0.0, 1.0),
                            ],
                            colors: [
                              baseColor,
                              highlightColor,
                              baseColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
