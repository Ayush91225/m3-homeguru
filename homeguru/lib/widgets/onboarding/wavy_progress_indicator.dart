import 'dart:math' as math;
import 'package:flutter/material.dart';

class WavyProgressIndicator extends StatefulWidget {
  const WavyProgressIndicator({
    super.key,
    required this.value,
    this.color,
    this.backgroundColor,
    this.height = 16.0,
    this.amplitude = 3.0,
    this.wavelength = 18.0,
  });

  final double value;
  final Color? color;
  final Color? backgroundColor;

  /// Overall container height (M3 spec default: 16)
  final double height;

  /// Wave amplitude — half the peak-to-trough distance (M3 spec default: 3)
  final double amplitude;

  /// Distance between wave peaks in logical pixels (M3 spec default: 18)
  final double wavelength;

  @override
  State<WavyProgressIndicator> createState() => _WavyProgressIndicatorState();
}

class _WavyProgressIndicatorState extends State<WavyProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = widget.color ?? cs.primary;
    final bg = widget.backgroundColor ?? cs.surfaceContainerHighest;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: widget.value, end: widget.value),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      builder: (context, progress, child) => AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) => CustomPaint(
          painter: _WavyPainter(
            progress: progress,
            phase: _ctrl.value,
            color: color,
            backgroundColor: bg,
            amplitude: widget.amplitude,
            wavelength: widget.wavelength,
          ),
          size: Size.fromHeight(widget.height),
        ),
      ),
    );
  }
}

class _WavyPainter extends CustomPainter {
  const _WavyPainter({
    required this.progress,
    required this.phase,
    required this.color,
    required this.backgroundColor,
    required this.amplitude,
    required this.wavelength,
  });

  final double progress;
  final double phase;
  final Color color;
  final Color backgroundColor;
  final double amplitude;
  final double wavelength;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    final trackRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      radius,
    );

    // Track
    canvas.drawRRect(trackRRect, Paint()..color = backgroundColor);

    if (progress <= 0) return;

    final fillWidth = size.width * progress.clamp(0.0, 1.0);
    final midY = size.height / 2;
    final phaseOffset = phase * wavelength;

    // Build wave path for the filled portion
    final path = Path();
    path.moveTo(0, midY);

    for (double x = 0; x <= fillWidth; x += 1) {
      final y = midY +
          amplitude *
              math.sin((x / wavelength * 2 * math.pi) - phaseOffset * 2 * math.pi / wavelength);
      path.lineTo(x, y);
    }

    // Close bottom
    path.lineTo(fillWidth, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Clip to track shape and draw
    canvas.save();
    canvas.clipRRect(trackRRect);
    canvas.drawPath(path, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_WavyPainter old) =>
      old.phase != phase ||
      old.progress != progress ||
      old.color != color;
}
