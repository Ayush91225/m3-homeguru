import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ui.Image? _cachedChillSheet;
bool _chillLoading = false;
final List<VoidCallback> _chillWaiters = [];

Future<void> _ensureChillSheet() async {
  if (_cachedChillSheet != null) return;
  if (_chillLoading) return;
  _chillLoading = true;
  try {
    final data = await rootBundle.load('assets/chill.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final f = await codec.getNextFrame();
    _cachedChillSheet = f.image;
  } catch (e) {
    debugPrint('Error loading chill sprite: $e');
  } finally {
    _chillLoading = false;
    for (final cb in _chillWaiters) { cb(); }
    _chillWaiters.clear();
  }
}

class ChillSprite extends StatefulWidget {
  const ChillSprite({super.key, this.size = 120});
  final double size;

  @override
  State<ChillSprite> createState() => _ChillSpriteState();
}

class _ChillSpriteState extends State<ChillSprite> {
  int _frame = 0;
  Timer? _timer;

  static const _frames = 2;
  static const _frameDuration = Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    if (_cachedChillSheet != null) {
      _startTimer();
    } else {
      _chillWaiters.add(_onReady);
      _ensureChillSheet();
    }
  }

  void _onReady() {
    if (mounted) { setState(() {}); _startTimer(); }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_frameDuration, (_) {
      if (mounted) setState(() => _frame = (_frame + 1) % _frames);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _chillWaiters.remove(_onReady);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedChillSheet == null) {
      return SizedBox(width: widget.size, height: widget.size);
    }
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _ChillPainter(
            image: _cachedChillSheet!,
            frame: _frame,
            totalFrames: _frames,
          ),
        ),
      ),
    );
  }
}

class _ChillPainter extends CustomPainter {
  const _ChillPainter({required this.image, required this.frame, required this.totalFrames});
  final ui.Image image;
  final int frame;
  final int totalFrames;

  @override
  void paint(Canvas canvas, Size size) {
    final frameW = image.width / totalFrames;
    final src = Rect.fromLTWH(frame * frameW, 0, frameW, image.height.toDouble());
    final dst = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, src, dst, Paint()..filterQuality = FilterQuality.medium);
  }

  @override
  bool shouldRepaint(_ChillPainter old) => old.frame != frame || old.image != image;
}
