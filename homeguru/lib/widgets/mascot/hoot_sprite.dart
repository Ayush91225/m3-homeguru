import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Singleton — decoded once, shared across all HootSprite instances.
ui.Image? _cachedSheet;
bool _loading = false;
final List<VoidCallback> _waiters = [];

Future<void> _ensureSheet() async {
  if (_cachedSheet != null) return;
  if (_loading) return;
  _loading = true;
  try {
    final data = await rootBundle.load('assets/hoot.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final f = await codec.getNextFrame();
    _cachedSheet = f.image;
  } catch (e) {
    debugPrint('Error loading mascot: $e');
  } finally {
    _loading = false;
    for (final cb in _waiters) { cb(); }
    _waiters.clear();
  }
}

class HootSprite extends StatefulWidget {
  const HootSprite({super.key, this.size = 96});
  final double size;

  @override
  State<HootSprite> createState() => _HootSpriteState();
}

class _HootSpriteState extends State<HootSprite> {
  int _frame = 0;
  Timer? _timer;

  static const _frames = 3;
  // 320ms per frame = ~1s per loop, feels natural for a simple blink/move
  static const _frameDuration = Duration(milliseconds: 320);

  @override
  void initState() {
    super.initState();
    if (_cachedSheet != null) {
      _startTimer();
    } else {
      _waiters.add(_onSheetReady);
      _ensureSheet();
    }
  }

  void _onSheetReady() {
    if (mounted) {
      setState(() {});
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_frameDuration, (_) {
      if (mounted) {
        setState(() => _frame = (_frame + 1) % _frames);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waiters.remove(_onSheetReady);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedSheet == null) {
      return SizedBox(width: widget.size, height: widget.size);
    }

    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _SpritePainter(
            image: _cachedSheet!,
            frame: _frame,
            totalFrames: _frames,
          ),
        ),
      ),
    );
  }
}

class _SpritePainter extends CustomPainter {
  const _SpritePainter({
    required this.image,
    required this.frame,
    required this.totalFrames,
  });

  final ui.Image image;
  final int frame;
  final int totalFrames;

  @override
  void paint(Canvas canvas, Size size) {
    // Dynamically calculate frame width based on the decoded image
    final frameW = image.width / totalFrames;
    final src = Rect.fromLTWH(
      frame * frameW,
      0,
      frameW,
      image.height.toDouble(),
    );
    final dst = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawImageRect(
      image,
      src,
      dst,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(_SpritePainter old) =>
      old.frame != frame || old.image != image;
}
