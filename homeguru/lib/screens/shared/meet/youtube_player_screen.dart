import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../services/meeting_signaling_service.dart';

class YouTubePlayerScreen extends StatefulWidget {
  final MeetingSignalingService? signalingService;

  const YouTubePlayerScreen({super.key, this.signalingService});

  @override
  State<YouTubePlayerScreen> createState() => _YouTubePlayerScreenState();
}

class _YouTubePlayerScreenState extends State<YouTubePlayerScreen> {
  final _urlController = TextEditingController();
  String? _currentVideoId;
  StreamSubscription? _syncSubscription;

  static const _suggested = [
    {'id': 'dQw4w9WgXcQ', 'title': 'Introduction to Quantum Mechanics', 'channel': 'MIT OpenCourseWare', 'duration': '12:45'},
    {'id': '9bZkp7q19f0', 'title': 'The History of Ancient Rome', 'channel': 'CrashCourse', 'duration': '18:20'},
    {'id': 'rfscVS0vtbw', 'title': 'Python Full Course for Beginners', 'channel': 'freeCodeCamp', 'duration': '4:26:52'},
    {'id': 'HXV3zeQKqGY', 'title': 'Calculus: Limits & Derivatives', 'channel': '3Blue1Brown', 'duration': '25:10'},
  ];

  @override
  void initState() {
    super.initState();
    _setupWebSocketSync();
  }

  void _setupWebSocketSync() {
    _syncSubscription = widget.signalingService?.messages.listen((msg) {
      if (msg['action'] == 'youtube-sync' && msg['state'] != null) {
        final state = msg['state'];
        if (state['videoId'] != null && state['videoId'] != _currentVideoId) {
          _openFullscreenVideo(state['videoId'], isHost: false);
        }
      }
    });
  }

  String? _extractVideoId(String input) {
    return YoutubePlayer.convertUrlToId(input);
  }

  void _openFullscreenVideo(String videoId, {bool isHost = true}) {
    setState(() => _currentVideoId = videoId);
    
    if (isHost) {
      widget.signalingService?.send({'action': 'youtube-sync', 'state': {'videoId': videoId}});
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullscreenVideoPlayer(
          videoId: videoId,
          isHost: isHost,
          onClose: () {
            setState(() => _currentVideoId = null);
            if (isHost) {
              widget.signalingService?.send({'action': 'youtube-sync', 'state': {'videoId': null}});
            }
          },
        ),
      ),
    );
  }

  void _handleShare() {
    final id = _extractVideoId(_urlController.text);
    if (id != null) {
      _openFullscreenVideo(id);
      _urlController.clear();
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _syncSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5))),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.play_circle_filled, size: 20, color: cs.error),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Watch Together', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
                      Text('Synced playback for everyone', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                Material(
                  color: cs.surfaceContainerLow,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      child: Icon(Icons.close, size: 15, color: cs.onSurfaceVariant),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(Icons.link, size: 16, color: cs.onSurfaceVariant),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _urlController,
                                decoration: InputDecoration(
                                  hintText: 'Paste YouTube link...',
                                  hintStyle: TextStyle(fontSize: 13, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500),
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(fontSize: 13, color: cs.onSurface, fontWeight: FontWeight.w500),
                                onSubmitted: (_) => _handleShare(),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: _urlController.text.trim().isEmpty ? cs.surfaceContainerLow : cs.error,
                      borderRadius: BorderRadius.circular(22),
                      child: InkWell(
                        onTap: _urlController.text.trim().isEmpty ? null : _handleShare,
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Icon(Icons.play_arrow, size: 14, color: _urlController.text.trim().isEmpty ? cs.onSurfaceVariant : cs.onError),
                              const SizedBox(width: 4),
                              Text('Play', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _urlController.text.trim().isEmpty ? cs.onSurfaceVariant : cs.onError)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text('SUGGESTED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant, letterSpacing: 1.2)),
                    const SizedBox(width: 12),
                    Expanded(child: Divider(color: cs.outlineVariant.withValues(alpha: 0.5), height: 1)),
                  ],
                ),
                const SizedBox(height: 12),
                ..._suggested.map((v) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => _openFullscreenVideo(v['id']!),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 120,
                                height: 72,
                                color: Colors.black,
                                child: Stack(
                                  children: [
                                    Image.network(
                                      'https://img.youtube.com/vi/${v['id']}/mqdefault.jpg',
                                      width: 120,
                                      height: 72,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
                                    ),
                                    Center(
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.7),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 4,
                                      right: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.7),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(v['duration']!, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(v['title']!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text(v['channel']!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: cs.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text('SYNCED PLAYBACK', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant, letterSpacing: 1.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FullscreenVideoPlayer extends StatefulWidget {
  const _FullscreenVideoPlayer({
    required this.videoId,
    required this.isHost,
    required this.onClose,
  });

  final String videoId;
  final bool isHost;
  final VoidCallback onClose;

  @override
  State<_FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<_FullscreenVideoPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    // Force landscape and hide system UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
        hideControls: !widget.isHost,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    // Restore portrait and system UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: () async {
        widget.onClose();
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: cs.tertiary,
                progressColors: ProgressBarColors(
                  playedColor: cs.tertiary,
                  handleColor: cs.tertiary,
                ),
              ),
            ),
            SafeArea(
              child: Positioned(
                top: 8,
                left: 8,
                child: Row(
                  children: [
                    Material(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () {
                          widget.onClose();
                          Navigator.pop(context);
                        },
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    if (!widget.isHost) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: cs.tertiary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'SYNCED PLAYBACK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
