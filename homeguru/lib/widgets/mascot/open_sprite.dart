import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ui.Image? _cachedOpenSheet;
bool _openLoading = false;
final List<VoidCallback> _openWaiters = [];

Future<void> _ensureOpenSheet() async {
  if (_cachedOpenSheet != null) return;
  if (_openLoading) return;
  _openLoading = true;
  try {
    final data = await rootBundle.load('assets/open.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final f = await codec.getNextFrame();
    _cachedOpenSheet = f.image;
  } catch (e) {
    debugPrint('Error loading open sprite: $e');
  } finally {
    _openLoading = false;
    for (final cb in _openWaiters) { cb(); }
    _openWaiters.clear();
  }
}

class OpenSprite extends StatefulWidget {
  const OpenSprite({super.key, this.size = 140});
  final double size;

  @override
  State<OpenSprite> createState() => _OpenSpriteState();
}

class _OpenSpriteState extends State<OpenSprite> {
  int _frame = 0;
  Timer? _timer;

  static const _totalFrames = 6;
  static const _frameDuration = Duration(milliseconds: 220);

  @override
  void initState() {
    super.initState();
    if (_cachedOpenSheet != null) {
      _startAnimation();
    } else {
      _openWaiters.add(_onReady);
      _ensureOpenSheet();
    }
  }

  void _onReady() {
    if (mounted) { setState(() {}); _startAnimation(); }
  }

  void _startAnimation() {
    _timer = Timer.periodic(_frameDuration, (t) {
      if (!mounted) { t.cancel(); return; }
      if (_frame >= _totalFrames - 1) {
        t.cancel();
        return;
      }
      setState(() => _frame++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _openWaiters.remove(_onReady);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedOpenSheet == null) {
      return SizedBox(width: widget.size, height: widget.size);
    }
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _OpenPainter(
            image: _cachedOpenSheet!,
            frame: _frame,
            totalFrames: _totalFrames,
          ),
        ),
      ),
    );
  }
}

class _OpenPainter extends CustomPainter {
  const _OpenPainter({required this.image, required this.frame, required this.totalFrames});
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
  bool shouldRepaint(_OpenPainter old) => old.frame != frame;
}
