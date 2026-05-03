import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ui.Image? _cachedTeacherSheet;
bool _teacherLoading = false;
final List<VoidCallback> _teacherWaiters = [];

Future<void> _ensureTeacherSheet() async {
  if (_cachedTeacherSheet != null) return;
  if (_teacherLoading) return;
  _teacherLoading = true;
  try {
    final data = await rootBundle.load('assets/teacher.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final f = await codec.getNextFrame();
    _cachedTeacherSheet = f.image;
  } catch (e) {
    debugPrint('Error loading teacher sprite: $e');
  } finally {
    _teacherLoading = false;
    for (final cb in _teacherWaiters) { cb(); }
    _teacherWaiters.clear();
  }
}

class TeacherSprite extends StatefulWidget {
  const TeacherSprite({super.key, this.size = 120, this.frameDuration = const Duration(milliseconds: 600)});
  final double size;
  final Duration frameDuration;

  @override
  State<TeacherSprite> createState() => _TeacherSpriteState();
}

class _TeacherSpriteState extends State<TeacherSprite> {
  int _frame = 0;
  Timer? _timer;
  static const _frames = 4;

  @override
  void initState() {
    super.initState();
    if (_cachedTeacherSheet != null) {
      _startTimer();
    } else {
      _teacherWaiters.add(_onReady);
      _ensureTeacherSheet();
    }
  }

  void _onReady() {
    if (mounted) { setState(() {}); _startTimer(); }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.frameDuration, (_) {
      if (mounted) setState(() => _frame = (_frame + 1) % _frames);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _teacherWaiters.remove(_onReady);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedTeacherSheet == null) {
      return SizedBox(width: widget.size, height: widget.size);
    }
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _TeacherPainter(
            image: _cachedTeacherSheet!,
            frame: _frame,
            totalFrames: _frames,
          ),
        ),
      ),
    );
  }
}

class _TeacherPainter extends CustomPainter {
  const _TeacherPainter({required this.image, required this.frame, required this.totalFrames});
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
  bool shouldRepaint(_TeacherPainter old) => old.frame != frame || old.image != image;
}
