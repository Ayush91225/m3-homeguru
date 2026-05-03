import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ui.Image? _cachedStudentSheet;
bool _studentLoading = false;
final List<VoidCallback> _studentWaiters = [];

Future<void> _ensureStudentSheet() async {
  if (_cachedStudentSheet != null) return;
  if (_studentLoading) return;
  _studentLoading = true;
  try {
    final data = await rootBundle.load('assets/student.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final f = await codec.getNextFrame();
    _cachedStudentSheet = f.image;
  } catch (e) {
    debugPrint('Error loading student sprite: $e');
  } finally {
    _studentLoading = false;
    for (final cb in _studentWaiters) { cb(); }
    _studentWaiters.clear();
  }
}

class StudentSprite extends StatefulWidget {
  const StudentSprite({super.key, this.size = 120, this.frameDuration = const Duration(milliseconds: 420)});
  final double size;
  final Duration frameDuration;

  @override
  State<StudentSprite> createState() => _StudentSpriteState();
}

class _StudentSpriteState extends State<StudentSprite> {
  int _frame = 0;
  Timer? _timer;

  static const _frames = 5;

  @override
  void initState() {
    super.initState();
    if (_cachedStudentSheet != null) {
      _startTimer();
    } else {
      _studentWaiters.add(_onReady);
      _ensureStudentSheet();
    }
  }

  void _onReady() {
    if (mounted) {
      setState(() {});
      _startTimer();
    }
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
    _studentWaiters.remove(_onReady);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedStudentSheet == null) {
      return SizedBox(width: widget.size, height: widget.size);
    }
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _StudentPainter(
            image: _cachedStudentSheet!,
            frame: _frame,
            totalFrames: _frames,
          ),
        ),
      ),
    );
  }
}

class _StudentPainter extends CustomPainter {
  const _StudentPainter({
    required this.image,
    required this.frame,
    required this.totalFrames,
  });

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
  bool shouldRepaint(_StudentPainter old) => old.frame != frame || old.image != image;
}
