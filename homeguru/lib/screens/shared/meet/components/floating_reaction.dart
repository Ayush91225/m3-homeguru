import 'package:flutter/material.dart';
import 'dart:math';

class FloatingReaction {
  final String emoji;
  final Key key;

  FloatingReaction({required this.emoji, required this.key});
}

class FloatingReactionWidget extends StatefulWidget {
  final String emoji;

  const FloatingReactionWidget({super.key, required this.emoji});

  @override
  State<FloatingReactionWidget> createState() => _FloatingReactionWidgetState();
}

class _FloatingReactionWidgetState extends State<FloatingReactionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _riseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late double _randomX;
  late double _wobble;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _randomX = rng.nextDouble() * 0.55 + 0.20;
    _wobble = (rng.nextDouble() - 0.5) * 40;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _riseAnimation = Tween<double>(begin: 0.10, end: 0.75).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 20),
    ]).animate(_controller);

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: size.width * _randomX + _wobble * _controller.value,
          bottom: size.height * _riseAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Text(
                widget.emoji,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
        );
      },
    );
  }
}
