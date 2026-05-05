import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'cc_shared.dart';

class RecSection extends StatefulWidget {
  final Map<String, dynamic> session;
  const RecSection({super.key, required this.session});

  @override
  State<RecSection> createState() => _RecSectionState();
}

class _RecSectionState extends State<RecSection> with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse('https://storage.googleapis.com/exoplayer-test-media-0/BigBuckBunny_320x180.mp4'),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    )..initialize().then((_) {
        if (mounted) setState(() => _initialized = true);
      }).catchError((_) {
        if (mounted) setState(() => _hasError = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(section: ClassSection.rec),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              color: Colors.black,
              child: _hasError
                  ? const AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Center(child: Icon(Icons.error_outline_rounded, color: Colors.white54, size: 40)),
                    )
                  : _initialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Center(child: CircularProgressIndicator()),
                    ),
            ),
          ),
        ),
        if (_initialized) ...[
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (_, value, x) {
              final pos = value.position;
              final dur = value.duration;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      ),
                      child: Slider(
                        value: pos.inMilliseconds.toDouble(),
                        max: dur.inMilliseconds.toDouble().clamp(1, double.infinity),
                        onChanged: (v) => _controller.seekTo(Duration(milliseconds: v.toInt())),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_fmt(pos), style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                          Text(_fmt(dur), style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10_rounded),
                onPressed: () async {
                  final pos = await _controller.position ?? Duration.zero;
                  _controller.seekTo(pos - const Duration(seconds: 10));
                },
              ),
              ValueListenableBuilder(
                valueListenable: _controller,
                builder: (_, value, x) => IconButton.filled(
                  iconSize: 32,
                  icon: Icon(value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  onPressed: () => value.isPlaying ? _controller.pause() : _controller.play(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.forward_10_rounded),
                onPressed: () async {
                  final pos = await _controller.position ?? Duration.zero;
                  _controller.seekTo(pos + const Duration(seconds: 10));
                },
              ),
            ],
          ),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Row(
            children: [
              Icon(Icons.access_time_rounded, size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(widget.session['duration'] ?? '', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(width: 16),
              Icon(Icons.person_outline_rounded, size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(widget.session['tutor'] ?? '', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}
